//
//  ModInfoConverter.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/25/25.
//


/// Parses modifierInfos into modifiers.
class ModInfoConverter {
  static func convert(modInfos: [ModifierData]) -> ([DogmaModifier], Int) {
    var dogmaModifiers: [DogmaModifier] = []
    var fails: Int = 0
    
    for modInfo in modInfos {
      let modOperator = ModOperator(rawValue: Int(modInfo.operation ?? 0))
      let affecteeFilter: ModAffecteeFilter? = ModAffecteeFilter(value: modInfo.func)
      
      let affecteeFilterExtraArg: Int64?
      switch affecteeFilter {
      case .owner_skillrq, .domain_skillrq: affecteeFilterExtraArg = modInfo.skillTypeID
      case .domain_group: affecteeFilterExtraArg = modInfo.groupId
      default: affecteeFilterExtraArg = nil
      }
      
      let dogmaModifier = DogmaModifier(
        affecteeFilter: affecteeFilter,
        affecteeFilterExtraArg: affecteeFilterExtraArg,
        affecteeDomain: ModDomain(value: modInfo.domain),
        affecteeAtributeId: AttrId(rawValue: modInfo.modifiedAttributeID ?? -1),
        modOperator: modOperator,
        aggregateMode: .stack, // ModAggregateMode?
        aggregateKey: nil, // AnyHashable?
        affectorAttrId: AttrId(rawValue: modInfo.modifyingAttributeID ?? -1)
      )
      
      dogmaModifiers.append(dogmaModifier)
    }
    
    return (dogmaModifiers, fails)
  }
  
  
}

/*
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
   aggregateMode: nil, // ModAggregateMode?
   aggregateKey: nil, // AnyHashable?
   affectorAttrId: AttrId(rawValue: value.modifyingAttributeID ?? -1)
 )
 */
