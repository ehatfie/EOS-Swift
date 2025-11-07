//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

class BasePythonModifier: BasePythonModifierProtocol {
  func reviseModification(message: Any, affectorItem: any BaseItemMixinProtocol) -> Bool {
    return false
  }
  
  var affecteeFilter: ModAffecteeFilter?

  var modDomain: ModDomain?

  var affecteeFilterExtraArg: Int64?

  var affecteeDomain: ModDomain?

  var affecteeAtributeId: Int64?

  // this could be a PythonModifier type only?
  func getModification(affectorItem: any BaseItemMixinProtocol)
    -> GetModResponse?
  {
    
    return nil
  }

  func reviseMessageTypes() {

  }

  func reviseModification(
    message: any Message,
    affectorItem: any BaseItemMixinProtocol
  ) -> Bool {
    return false
  }

  init(
    affecteeFilter: ModAffecteeFilter? = nil,
    modDomain: ModDomain? = nil,
    affecteeFilterExtraArg: Int64? = nil,
    affecteeDomain: ModDomain? = nil,
    affecteeAtributeId: Int64? = nil
  ) {
    self.affecteeFilter = affecteeFilter
    self.modDomain = modDomain
    self.affecteeFilterExtraArg = affecteeFilterExtraArg
    self.affecteeDomain = affecteeDomain
    self.affecteeAtributeId = affecteeAtributeId
  }

}

class AncillaryRepAmountModifier: BasePythonModifier {
  init() {
    super.init(
      affecteeFilter: .item,
      affecteeDomain: .me,
      affecteeAtributeId: AttrId.armor_dmg_amount.rawValue
    )
  }

  override func getModification(affectorItem: any BaseItemMixinProtocol)
    -> GetModResponse?
  {
    let value: Double?
    if let charge = affectorItem as? Charge,
      charge.typeId == TypeId.naniteRepairPaste.rawValue
    {
      value = affectorItem.attributes?[AttrId.charged_armor_dmg_mult.rawValue]
    } else {
      value = 1
    }

    return GetModResponse(
      modOperator: .post_mul_immune,
      modValue: value,
      aggregateMode: .stack,
      aggregateKey: nil
    )
  }

  override func reviseModification(
    message: any Message,
    affectorItem: any BaseItemMixinProtocol
  ) -> Bool {
    switch message {
    case is ItemAdded:
      return reviseOnItemAddedRemoved(
        message: message as! ItemMessage,
        affectorItem: affectorItem
      )
    case is ItemRemoved:
      return reviseOnItemAddedRemoved(
        message: message as! ItemMessage,
        affectorItem: affectorItem
      )
    case is AttributesValueChanged:
      return reviseOnAttributeChanged(
        message: message as! AttributeMessage,
        affectorItem: affectorItem
      )
    default: return false
    }
  }

  func reviseOnItemAddedRemoved(
    message: any ItemMessage,
    affectorItem: any BaseItemMixinProtocol
  ) -> Bool {
    if let charge = affectorItem as? Charge,
      let messageCharge = message.item as? Charge,
      charge == messageCharge,
      message.item.typeId == TypeId.naniteRepairPaste.rawValue
    {
      return true
    }

    return false
  }

  /// If armor rep multiplier changes, then result of modification also should change.
  func reviseOnAttributeChanged(
    message: any AttributeMessage,
    affectorItem: any BaseItemMixinProtocol
  ) -> Bool {
    guard let mixin = affectorItem as? BaseItemMixin else {
      return false
    }

    if let value = message.attributeChanges[mixin],
       value.contains(AttrId.charged_armor_dmg_mult.rawValue)
    {
      return true
    }

    return false
  }
}

extension AncillaryRepAmountModifier {
  static func makePasteEffect() -> FueledArmorRepair {
    return FueledArmorRepair(
      effectId: EosEffectId.ancillary_paste_armor_rep_boost.rawValue,
      categoryID: EffectCategoryId.passive,
      isOffensive: false,
      isAssistance: false,
      buildStatus: .custom,
      modifiers: [AncillaryRepAmountModifier()]
    )
  }
}
