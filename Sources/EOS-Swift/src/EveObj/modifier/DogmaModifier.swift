//
//  Dogma.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

class BaseModifier: BaseModifierProtocol {
  var affecteeFilter: ModAffecteeFilter?

  var modDomain: ModDomain?

  var affecteeFilterExtraArg: Int64?

  var affecteeDomain: ModDomain?

  var affecteeAtributeId: Int64?

  func getModification(affectorItem: any BaseItemMixinProtocol) -> GetModResponse? {
    return nil
  }

  init(
    affecteeFilter: ModAffecteeFilter? = nil,
    affecteeFilterExtraArg: Int64? = nil,
    affecteeDomain: ModDomain? = nil,
    affecteeAtributeId: Int64? = nil
  ) {
    self.affecteeFilter = affecteeFilter
    self.affecteeFilterExtraArg = affecteeFilterExtraArg
    self.affecteeDomain = affecteeDomain
    self.affecteeAtributeId = affecteeAtributeId
  }

}

class DogmaModifier: BaseModifierProtocol {
  var affecteeFilter: ModAffecteeFilter?
  var affecteeFilterExtraArg: Int64?
  var affecteeDomain: ModDomain?
  var affecteeAtributeId: Int64?
  var modOperator: ModOperator?
  var aggregateMode: ModAggregateMode?
  var aggregateKey: AnyHashable?
  var affectorAttributeId: Int64?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(affecteeFilter)
    hasher.combine(affecteeFilterExtraArg)
    hasher.combine(affecteeDomain)
    hasher.combine(affecteeAtributeId)
    hasher.combine(modOperator)
    hasher.combine(aggregateMode)
    hasher.combine(aggregateKey)
    hasher.combine(affectorAttributeId)
    
  }
  

  init(
    affecteeFilter: ModAffecteeFilter? = nil,
    affecteeFilterExtraArg: Int64? = nil,
    affecteeDomain: ModDomain? = nil,
    affecteeAtributeId: Int64? = nil,
    modOperator: ModOperator? = nil,
    aggregateMode: ModAggregateMode? = nil,
    aggregateKey: AnyHashable? = nil,
    affectorAttrId: Int64? = nil
  ) {
    
    if affecteeAtributeId == nil {
      print("++ DogmaModifier init affecteeAttributeId is nil")
    }
    self.affecteeFilter = affecteeFilter
    self.affecteeFilterExtraArg = affecteeFilterExtraArg
    self.affecteeDomain = affecteeDomain
    self.affecteeAtributeId = affecteeAtributeId

    self.modOperator = modOperator
    self.aggregateMode = aggregateMode
    self.aggregateKey = aggregateKey
    self.affectorAttributeId = affectorAttrId
  }

  convenience init(buffTemplate: BuffTemplate, affectorAttributeId: Int64) {
    self.init(
      affecteeFilter: buffTemplate.affecteeFilter,
      affecteeFilterExtraArg: buffTemplate.affecteeFilterExtraArg,
      affecteeDomain: .target,
      affecteeAtributeId: buffTemplate.affecteeAtributeId,
      modOperator: buffTemplate.modOperator,
      aggregateMode: buffTemplate.aggregateMode,
      aggregateKey: buffTemplate.buffId,
      affectorAttrId: affectorAttributeId
    )
  }

  func getModification(affectorItem: any BaseItemMixinProtocol) -> GetModResponse? {
    guard let affectorAttributeId else {
      print("++ no affectorAttributeId for \(self)")
      return nil } // throw??
    let attributeValue = affectorItem.attributes?[affectorAttributeId]
    if attributeValue == nil {
      print("+")
    }
    return GetModResponse(
      modOperator: self.modOperator,
      modValue: attributeValue,
      aggregateMode: self.aggregateMode,
      aggregateKey: self.aggregateKey
    )
    /*
     var modOperator: ModOperator?
     let modValue: Double?
     let resistValue: Double?
     let attributeValue: Double?
     let aggregateMode: ModAggregateMode?
     let aggregateKey: AnyHashable?
     */
  }
  
  var valid: Bool {
    let base = validateBase()
    let operatorValid = self.modOperator != nil && ModOperator.allCases.contains(self.modOperator!)
    let aggregateModeValid = self.aggregateMode != nil && ModAggregateMode.allCases.contains(self.aggregateMode!)
    
    let other = (self.aggregateKey == nil && self.aggregateMode == .stack) || self.aggregateKey != nil
    
    return base && operatorValid && aggregateModeValid && other
  }
}

struct ModificationData {
  var modOperator: ModOperator?
  let modValue: Double?
  let resistValue: Double?
  let attributeValue: Double?
  let aggregateMode: ModAggregateMode?
  let aggregateKey: AnyHashable?
  let affectorItem: (any BaseItemMixinProtocol)?
}
