//
//  EveObjectBuilder.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//

class EveObjectBuilder: @unchecked Sendable {

  nonisolated(unsafe)
    static func run(dataHandler: any DataHandlerProtocol) async -> (
      [Attribute],
      [Effect],
      [ItemType],
      [BuffTemplate]
    )
  {
    let eveTypes = await dataHandler.getEveTypes()
    let eveGroups = await dataHandler.getEveGroups()
    let dogmaAttributes = await dataHandler.getDogmaAttributes()
    let dogmaTypeAttributes = await dataHandler.getDogmaTypeAttributes().map {
      ($0.0, DogmaTypeAttributeData(typeID: $0.0, attributeID: $0.1.attributeID, value: $0.1.value))
    }
    let dogmaEffects = await dataHandler.getDogmaEffects()
    let dogmaTypeEffects = await dataHandler.getDogmaTypeEffects()
    let dbuffCollections = await dataHandler.getDebuffCollection()
    let skillReqs = await dataHandler.getSkillReqs()
    // let typeFighterAbils = await dataHandler.getTypeFighterAbils()

    return await convert(
      typeData: eveTypes,
      eveGroups: eveGroups,
      dogmaTypeEffects: dogmaTypeEffects,
      dogmaTypeAttributes: dogmaTypeAttributes,
      skillReqs: skillReqs,
      dogmaAttributes: dogmaAttributes,
      dogmaEffects: dogmaEffects
    )
  }

  static func convert(
    typeData: [EveTypeData],
    eveGroups: [EveGroupData],
    dogmaTypeEffects: [DogmaTypeEffect],
    dogmaTypeAttributes: [(Int64, DogmaTypeAttributeData)],
    skillReqs: [TypeSkillReq],
    dogmaAttributes: [DogmaAttributeData],
    dogmaEffects: [DogmaEffectData]
  ) async -> (
    [Attribute],
    [Effect],
    [ItemType],
    [BuffTemplate]
  ) {
    var keyedGroups: [Int64: EveGroupData] = [:]
    for row in eveGroups {
      keyedGroups[row.groupID] = row
    }

    var typesDefaultEffectMap: [Int64: Int64] = [:]

    for (row) in dogmaTypeEffects {
      guard row.isDefault else { continue }
      typesDefaultEffectMap[row.typeId] = row.effectID
    }

    var typesEffects: [Int64: Set<EffectId>] = [:]
    for (row) in dogmaTypeEffects {
      typesEffects[row.typeId, default: []].insert(
        EffectId(rawValue: Int(row.effectID))!
      )
    }

    var typesAttributes: [Int64: [AttrId: Double]] = [:]

    for (typeId, row) in dogmaTypeAttributes {
      var attributesForType = typesAttributes[typeId, default: [:]]
      guard let attrId = AttrId(rawValue: row.attributeID) else { continue }
      attributesForType[attrId] = Double(row.value)
      if row.attributeID == 272 {
        print("++ attribute value \(row.value)")
      }
      typesAttributes[typeId] = attributesForType
    }

    //var typesAbilitiesData: [Int64: [A]]
    var typesSkillReqData: [Int64: [Int64: Int64]] = [:]

    for row in skillReqs {
      var skillReqsForType = typesSkillReqData[row.typeId, default: [:]]
      skillReqsForType[row.skillTypeId] = row.level
      typesSkillReqData[row.typeId] = skillReqsForType
    }

    // Convert attributes

    var attributes: [Attribute] = []
    for row in dogmaAttributes {
      attributes.append(
        Attribute(
          attr_id: row.attributeID,
          max_attr_id: row.maxAttributeID,
          default_value: row.defaultValue,
          high_is_good: row.highIsGood,
          stackable: row.stackable
        )
      )
    }
    print("++ Converted attributes: \(attributes.count) from \(dogmaAttributes.count)")
    // Convert effects
    var effects: [Effect] = []
    for row in dogmaEffects {
      let effectData = row
      let modifiers = effectData.modifierInfo?.map { value -> DogmaModifier in
        let modOperator = ModOperator(rawValue: Int(value.operation ?? 0))
        let affecteeFilter: ModAffecteeFilter? = ModAffecteeFilter(
          value: value.func
        )

        let affecteeFilterExtraArg: Int64?
        switch affecteeFilter {
        case .owner_skillrq, .domain_skillrq:
          affecteeFilterExtraArg = value.skillTypeID
        case .domain_group: affecteeFilterExtraArg = value.groupId
        default: affecteeFilterExtraArg = nil
        }

        return DogmaModifier(
          affecteeFilter: affecteeFilter,
          affecteeFilterExtraArg: affecteeFilterExtraArg,
          affecteeDomain: ModDomain(value: value.domain),
          affecteeAtributeId: AttrId(rawValue: value.modifiedAttributeID ?? -1),
          modOperator: modOperator,
          aggregateMode: .stack,  // ModAggregateMode?
          aggregateKey: nil,  // AnyHashable?
          affectorAttrId: AttrId(rawValue: value.modifyingAttributeID ?? -1)
        )
      }

      effects.append(
        Effect(
          effectId: effectData.effectID,
          categoryID: EffectCategoryId(rawValue: effectData.effectCategory),
          isOffensive: effectData.isOffensive,
          isAssistance: effectData.isAssistance,
          durationAttributeID: effectData.durationAttributeID,
          dischargeAttributeID: effectData.dischargeAttributeID,
          rangeAttributeID: effectData.rangeAttributeID,
          falloffAttributeID: effectData.falloffAttributeID,
          trackingSpeedAttributeID: effectData.trackingSpeedAttributeID,
          fittingUseUsageChanceAttributeID: effectData
            .fittingUsageChanceAttributeID,
          resistanceAttributeId: effectData.resistanceAttributeID,
          buildStatus: .none,
          modifiers: modifiers ?? []
        )
      )
    }
    print("++ Converted effects: \(effects.count) from \(dogmaEffects.count)")
    // Convert types

    var itemType: [ItemType] = []
    var effectMap: [EffectId: Effect] = [:]
    for e in effects {
      guard let effectId = EffectId(rawValue: Int(e.effectId)) else {
        //print("++ no effect for effectId \(e.effectId)")
        continue
      }
      effectMap[effectId] = e
    }

    for row in typeData {
      let typeID = row.typeID
      let defaultEffectTypeId = typesDefaultEffectMap[typeID]
      let defaultEffect: Effect?
      
      if let defaultEffectTypeId {
        defaultEffect = effectMap[EffectId(rawValue: Int(defaultEffectTypeId))!]
      } else {
        defaultEffect = nil
      }
      
      itemType.append(
        ItemType(
          typeId: typeID,
          groupId: row.groupID!,
          categoryId: keyedGroups[row.groupID!]?.categoryID ?? 0,
          attributes: typesAttributes[typeID, default: [:]],
          effects: effectMap,
          defaultEffect: defaultEffect,
          abilitiesData: [:],
          requiredSkills: typesSkillReqData[typeID, default: [:]]
        )
      )
    }
    
    /*
     # Convert buff templates
     buff_templates = []
     for row in data['dbuffcollections']:
         buff_templates.extend(WarfareBuffTemplateBuilder.build(row))
     */

    return (
      attributes,
      effects,
      itemType,
      []
    )
  }
}
