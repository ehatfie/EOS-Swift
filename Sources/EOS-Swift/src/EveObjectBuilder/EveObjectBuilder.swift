//
//  EveObjectBuilder.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//

class EveObjectBuilder: @unchecked Sendable {
  
  nonisolated(unsafe)
  static func run(dataHandler: any DataHandlerProtocol) async -> ([EveTypeData]) {
    let eveTypes = await dataHandler.getEveTypes()
    let eveGroups = await dataHandler.getEveGroups()
    let dogmaAttributes = await dataHandler.getDogmaAttributes()
    let dogmaTypeAttributes = await dataHandler.getDogmaTypeAttributes()
    let dogmaEffects = await dataHandler.getDogmaEffects()
    let dogmaTypeEffects = await dataHandler.getDogmaTypeEffects()
    let dbuffCollections = await dataHandler.getDebuffCollection()
    let skillReqs = await dataHandler.getSkillReqs()
    // let typeFighterAbils = await dataHandler.getTypeFighterAbils()
    
    return (
      eveTypes
    )
  }
  
  static func convert(
    eveGroups: [EveGroupData],
    dogmaTypeEffects: [(Int64, DogmaTypeEffectData)],
    dogmaTypeAttributes: [(Int64, DogmaTypeAttributeData)],
    skillReqs: [TypeSkillReq],
    dogmaAttributes: [DogmaAttributeData],
    dogmaEffects: [DogmaEffectData]
  ) async -> (
    [Attribute],
    [Effect],
    [EveTypeData],
    [BuffTemplate]
  ) {
    var keyedGroups: [Int64: EveGroupData] = [:]
    for row in eveGroups {
      keyedGroups[row.groupID] = row
    }
    
    var typesDefaultEffectMap: [Int64: Int64] = [:]
    
    for (typeId, row) in dogmaTypeEffects {
      guard row.isDefault else { continue }
      typesDefaultEffectMap[typeId] = row.effectID
    }
    
    var typeEffects: [Int64: Set<EffectId>] = [:]
    for (typeId, row) in dogmaTypeEffects {
      typeEffects[typeId, default: []].insert(EffectId(rawValue: Int(row.effectID))!)
    }
    
    var typesAttributes: [Int64: [AttrId: Double]] = [:]
    
    for (typeId, row) in dogmaTypeAttributes {
      var attributesForType = typesAttributes[typeId, default: [:]]
      attributesForType[AttrId(rawValue: row.attributeID)!] = Double(row.value)
      typesAttributes[typeId] = attributesForType
    }
    
    //var typesAbilitiesData: [Int64: [A]]
    var typesSkillReqData: [Int64: [Int64: Int64]] = [:]
    
    for row in skillReqs {
      var skillReqsForType = typesSkillReqData[row.typeId, default: [:]]
      skillReqsForType[row.skillTypeId] = row.level
      typesSkillReqData[row.typeId] = skillReqsForType
    }
    
    var effects: [Effect] = []
    
    for row in dogmaEffects {
      let effectData = row
      let modifiers = effectData.modifierInfo?.map { value -> DogmaModifier in
        let modOperator = ModOperator(rawValue: Int(value.operation ?? 0))
        let affecteeFilter: ModAffecteeFilter? = ModAffecteeFilter(value: value.func)
        
        let affecteeFilterExtraArg: Int64?
        switch affecteeFilter {
        case .owner_skillrq, .domain_skillrq: affecteeFilterExtraArg = value.skillTypeID
        case .domain_group: affecteeFilterExtraArg = value.groupId
        default: affecteeFilterExtraArg = nil
        }
        
        return DogmaModifier(
          affecteeFilter: affecteeFilter,
          affecteeFilterExtraArg: affecteeFilterExtraArg,
          affecteeDomain: ModDomain(value: value.domain),
          affecteeAtributeId: AttrId(rawValue: value.modifiedAttributeID ?? -1),
          modOperator: modOperator,
          aggregateMode: .stack, // ModAggregateMode?
          aggregateKey: nil, // AnyHashable?
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
          fittingUseUsageChanceAttributeID: effectData.fittingUsageChanceAttributeID,
          resistanceAttributeId: effectData.resistanceAttributeID,
          buildStatus: .none,
          modifiers: modifiers ?? []
        )
      )
    }
    
    return (
      [],
      [],
      [],
      []
    )
  }
}
