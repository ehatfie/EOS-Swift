//
//  EveObjectBuilder.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//
import Foundation

class EveObjectBuilder: @unchecked Sendable {

  nonisolated(unsafe)
    static func run(dataHandler: any DataHandlerProtocol) async -> (
      [Attribute],
      [Effect],
      [ItemType],
      [BuffTemplate]
    )
  {
    
    print("++ eveBuilder run")
    var start = Date()
    let eveTypes = await dataHandler.getEveTypes()
    print("++ evetypes took \(Date().timeIntervalSince(start))s")
    start = Date()
    let eveGroups = await dataHandler.getEveGroups()
    print("++ eveGroups took \(Date().timeIntervalSince(start))s")
    start = Date()
    let dogmaAttributes = await dataHandler.getDogmaAttributes()
    print("++ dogmaAttributes took \(Date().timeIntervalSince(start))s")
    start = Date()
    let dogmaTypeAttributes = await dataHandler.getDogmaTypeAttributes()
    print("** dogmaTypeAttributes took \(Date().timeIntervalSince(start))s to get \(dogmaTypeAttributes.count)")
    
    start = Date()
    let dogmaEffects = await dataHandler.getDogmaEffects()
    print("++ dogmaEffects took \(Date().timeIntervalSince(start))s")
    
    start = Date()
    let dogmaTypeEffects = await dataHandler.getDogmaTypeEffects()
    print("++ dogmaTypeEffects took \(Date().timeIntervalSince(start))s")
    
    start = Date()
    let dbuffCollections = await dataHandler.getDebuffCollection()
    print("++ dbuffCollections took \(Date().timeIntervalSince(start))s")
    
    start = Date()
    let skillReqs = await dataHandler.getSkillReqs()
    print("++ skillReqs tok \(Date().timeIntervalSince(start))s")
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
    dogmaTypeAttributes: [DogmaTypeAttributeData],
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
      guard let effectID = EffectId(rawValue: Int(row.effectID)) else {
        continue
      }
      if effectID == .projectile_fired {
        print("++ found projectile fired for \(row.typeId)")
      }
      typesEffects[row.typeId, default: []].insert(
        effectID
      )
    }
    print("++ typesEffects has 2929 \(typesEffects[2929] != nil)")
    var typesAttributes: [Int64: [AttrId: Double]] = [:]
    print("** convert got \(dogmaTypeAttributes.count) dogmaTypeAttributes")
    for row in dogmaTypeAttributes {
      var attributesForType = typesAttributes[row.typeID, default: [:]]
      guard let attrId = AttrId(rawValue: row.attributeID) else { continue }
      attributesForType[attrId] = Double(row.value)
//      if row.attributeID == 272 {
//        print("++ attribute value \(row.value)")
//      }
      typesAttributes[row.typeID] = attributesForType
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
      
      guard let effectID = EffectId(rawValue: Int(effectData.effectID)) else {
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
            resistanceAttributeID: effectData.resistanceAttributeID,
            buildStatus: .none,
            modifiers: modifiers ?? []
          )
        )
        continue
      }
      switch effectID {
      case .projectile_fired:
        ProjectileFiredEffect(
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
          resistanceAttributeID: effectData.resistanceAttributeID,
          buildStatus: .none,
          modifiers: modifiers ?? []
        )
      default:
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
            resistanceAttributeID: effectData.resistanceAttributeID,
            buildStatus: .none,
            modifiers: modifiers ?? []
          )
        )
      }

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
    
    print("** converted type attributes \(typesAttributes.count)")
    for row in typeData {
      let typeID = row.typeID
      let defaultEffectTypeId = typesDefaultEffectMap[typeID]
      let defaultEffect: Effect?
      
      if let defaultEffectTypeId, let effectId = EffectId(rawValue: Int(defaultEffectTypeId)) {
        defaultEffect = effectMap[effectId]
      } else {
        defaultEffect = nil
      }
      let effects = typesEffects[typeID, default: []]
      var ourEffectMap: [EffectId: Effect] = [:]
      
      for effect in effects {
        ourEffectMap[effect] = effectMap[effect]
      }

      itemType.append(
        ItemType(
          typeId: typeID,
          groupId: row.groupID!,
          categoryId: keyedGroups[row.groupID!]?.categoryID ?? 0,
          attributes: typesAttributes[typeID, default: [:]],
          effects: ourEffectMap,
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
