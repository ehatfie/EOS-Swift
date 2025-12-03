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
    var dogmaTypeAttributes = await dataHandler.getDogmaTypeAttributes()
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
    
    // need to update the DogmaTypeAttributes with mock data from the types
    
    dogmaTypeAttributes
    
    var attrIds: Set<Int64> = [
      AttrId.radius.rawValue,
      AttrId.mass.rawValue,
      AttrId.volume.rawValue,
      AttrId.capacity.rawValue,
    ]
    
    var definedPairs: Set<KeyValueKey> = []
    for value in dogmaTypeAttributes {
      guard attrIds.contains(value.attributeID) else { continue }
      definedPairs.insert(KeyValueKey(key: value.typeID, value: value.attributeID))
    }
    var attributesSkipped = 0
    
    for row in eveTypes {
      let typeID = row.typeID
      
      if let radius = row.radius {
        let radiusAttr = AttrId.radius
        let testKey = KeyValueKey(key: typeID, value: radiusAttr.rawValue)
        if definedPairs.contains(testKey) {
          attributesSkipped += 1
          continue
        }
        dogmaTypeAttributes.append(
          DogmaTypeAttributeData(
            typeID: typeID,
            attributeID: radiusAttr.rawValue,
            value: Double(radius)
          )
        )
      }
      
      if let value = row.mass {
        let attr = AttrId.mass
        let testKey = KeyValueKey(key: typeID, value: attr.rawValue)
        if definedPairs.contains(testKey) {
          attributesSkipped += 1
          continue
        }
        dogmaTypeAttributes.append(
          DogmaTypeAttributeData(
            typeID: typeID,
            attributeID: attr.rawValue,
            value: Double(value)
          )
        )
      }
      
      if let value = row.volume {
        let attr = AttrId.volume
        let testKey = KeyValueKey(key: typeID, value: attr.rawValue)
        if definedPairs.contains(testKey) {
          attributesSkipped += 1
          continue
        }
        dogmaTypeAttributes.append(
          DogmaTypeAttributeData(
            typeID: typeID,
            attributeID: attr.rawValue,
            value: Double(value)
          )
        )
      }
      
      if let value = row.capacity {
        let attr = AttrId.capacity
        let testKey = KeyValueKey(key: typeID, value: attr.rawValue)
        if definedPairs.contains(testKey) {
          attributesSkipped += 1
          continue
        }
        
        dogmaTypeAttributes.append(
          DogmaTypeAttributeData(
            typeID: typeID,
            attributeID: attr.rawValue,
            value: Double(value)
          )
        )
      }
    }
    
    if attributesSkipped > 0 {
      print("++ skipped normallizing attributes")
    }
    
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

    var typesEffects: [Int64: Set<Int64>] = [:]
    for (row) in dogmaTypeEffects {
//      guard let effectID = EffectId(rawValue: Int(row.effectID)) else {
//        continue
//      }
//      if effectID == .projectile_fired {
//        print("++ found projectile fired for \(row.typeId)")
//      }
      typesEffects[row.typeId, default: []].insert(
        row.effectID
      )
    }
    print("++ typesEffects has 2929 \(typesEffects[2929] != nil)")
    var typesAttributes: [Int64: [Int64: Double]] = [:]
    print("** convert got \(dogmaTypeAttributes.count) dogmaTypeAttributes")
    for row in dogmaTypeAttributes {
      var attributesForType = typesAttributes[row.typeID, default: [:]]
      attributesForType[row.attributeID] = Double(row.value)
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
          affecteeAtributeId: value.modifiedAttributeID,
          modOperator: modOperator,
          aggregateMode: .stack,  // ModAggregateMode?
          aggregateKey: nil,  // AnyHashable?
          affectorAttrId: value.modifyingAttributeID
        )
      }
      
      guard let effectID = EffectId(rawValue: effectData.effectID) else {
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
        if effectData.effectID == 34 {
          print("++")
        }
        continue
      }
      switch effectID {
      case .projectile_fired:

        effects.append(
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

    var itemTypes: [ItemType] = []
    var effectMap: [Int64: Effect] = [:]
    for e in effects {
//      guard let effectId = EffectId(rawValue: Int(e.effectId)) else {
//        //print("++ no effect for effectId \(e.effectId)")
//        continue
//      }
      effectMap[e.effectId] = e
    }
    
    print("** converted type attributes \(typesAttributes.count)")
    for row in typeData {
      let typeID = row.typeID
      let defaultEffectTypeId = typesDefaultEffectMap[typeID]
      let defaultEffect: Effect?
//      if let defaultEffectTypeId {
//        if let effectId = EffectId(rawValue: Int(defaultEffectTypeId)) {
//          
//        } else {
//          print("** item named \(row.name) has defaultEffectTypeID \(defaultEffectTypeId) but doesnt make an EffectID")
//        }
//      } else {
//        print("** \(row.name) has no defaultEffectTypeID")
//      }
      if let defaultEffectTypeId {
        defaultEffect = effectMap[defaultEffectTypeId]
      } else {
        defaultEffect = nil
      }
      let effects = typesEffects[typeID, default: []]
      if typeID == 2929 {
        print("&& loaded effects for \(typeID): \(effects)")
      }
      var ourEffectMap: [Int64: Effect] = [:]
      
      for effect in effects {
        ourEffectMap[effect] = effectMap[effect]
      }
      let typeEffectIds = typesEffects[typeID, default: []]
      // effects=tuple(effect_map[eid] for eid in type_effect_ids),
      let effects1 = typeEffectIds.compactMap { effectMap[$0] }
      let itemType = ItemType(
        name: row.name,
        typeId: typeID,
        groupId: row.groupID!,
        categoryId: keyedGroups[row.groupID!]?.categoryID ?? 0,
        attributes: typesAttributes[typeID, default: [:]],
        effects: ourEffectMap,
        defaultEffect: defaultEffect,
        abilitiesData: [:],
        requiredSkills: typesSkillReqData[typeID, default: [:]]
      )
      
      itemTypes.append(
        itemType
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
      itemTypes,
      []
    )
  }
}
