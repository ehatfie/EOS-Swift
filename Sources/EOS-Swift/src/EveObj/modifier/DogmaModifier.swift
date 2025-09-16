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

  var affecteeAtributeId: AttrId?

  func getModification(affectorItem: any BaseItemMixinProtocol) -> ModificationData? {
    return nil
  }

  init(
    affecteeFilter: ModAffecteeFilter? = nil,
    affecteeFilterExtraArg: Int64? = nil,
    affecteeDomain: ModDomain? = nil,
    affecteeAtributeId: AttrId? = nil
  ) {
    self.affecteeFilter = affecteeFilter
    self.affecteeFilterExtraArg = affecteeFilterExtraArg
    self.affecteeDomain = affecteeDomain
    self.affecteeAtributeId = affecteeAtributeId
  }

}

class DogmaModifier: BaseModifierProtocol {
  var affecteeFilter: ModAffecteeFilter?

  var modDomain: ModDomain?

  var affecteeFilterExtraArg: Int64?

  var affecteeDomain: ModDomain?

  var affecteeAtributeId: AttrId?

  var modOperator: ModOperator?
  var aggregateMode: ModAggregateMode?
  var aggregateKey: AnyHashable?
  var affectorAttributeId: AttrId?

  init(
    affecteeFilter: ModAffecteeFilter? = nil,
    affecteeFilterExtraArg: Int64? = nil,
    affecteeDomain: ModDomain? = nil,
    affecteeAtributeId: AttrId? = nil,
    modOperator: ModOperator? = nil,
    aggregateMode: ModAggregateMode? = nil,
    aggregateKey: AnyHashable? = nil,
    affectorAttrId: AttrId? = nil
  ) {
    self.affecteeFilter = affecteeFilter
    self.affecteeFilterExtraArg = affecteeFilterExtraArg
    self.affecteeDomain = affecteeDomain
    self.affecteeAtributeId = affecteeAtributeId

    self.modOperator = modOperator
    self.aggregateMode = aggregateMode
    self.aggregateKey = aggregateKey
    self.affectorAttributeId = affectorAttrId
  }

  convenience init(buffTemplate: BuffTemplate, affectorAttributeId: AttrId) {
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

  func getModification(affectorItem: any BaseItemMixinProtocol) -> ModificationData? {
    guard let affectorAttributeId else { return nil } // throw??
    let attributeValue = affectorItem.attributes[affectorAttributeId]

    return ModificationData(
      modOperator: self.modOperator,
      attributeValue: attributeValue,
      aggregateMode: self.aggregateMode,
      aggregateKey: self.aggregateKey
    )
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
  //self.operator, value, self.aggregate_mode, self.aggregate_key
  var modOperator: ModOperator?
  let attributeValue: Double?
  let aggregateMode: ModAggregateMode?
  let aggregateKey: AnyHashable?
}

struct BuffTemplate {
  var affecteeFilter: ModAffecteeFilter?
  var affecteeFilterExtraArg: Int64?
  var affecteeAtributeId: AttrId?
  var modOperator: ModOperator?
  var aggregateMode: ModAggregateMode?
  var buffId: AnyHashable
}
