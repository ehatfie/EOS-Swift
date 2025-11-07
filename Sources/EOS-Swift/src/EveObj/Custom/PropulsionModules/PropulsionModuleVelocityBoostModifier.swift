//
//  PropulsionModuleVelocityBoostModifier.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

class PropulsionModuleVelocityBoostModifier: BasePythonModifier {

  init() {
    super.init(
      affecteeFilter: .item,
      affecteeFilterExtraArg: nil,
      affecteeDomain: .ship,
      affecteeAtributeId: AttrId.max_velocity.rawValue,
    )
  }

  override func getModification(affectorItem: any BaseItemMixinProtocol)
    -> GetModResponse?
  {
    guard let ship = affectorItem.fit?.ship else { return nil }

    /// If attribute values of any necessary items are not available, do not calculate anything
    guard
      let mass = ship.attributes?[AttrId.mass.rawValue],
      let speedBoost = ship.attributes?[AttrId.speed_factor.rawValue],
      let thrust = ship.attributes?[AttrId.speed_boost_factor.rawValue]
    else { return nil }
    let perc = (speedBoost * thrust) / mass
    let mult = 1 * perc / 100

    return GetModResponse(
      modOperator: .post_mul,
      modValue: mult,
      aggregateMode: .stack,
      aggregateKey: nil
    )
  }
  
  override func reviseModification(message: Any, affectorItem: any BaseItemMixinProtocol)
    -> Bool
  {
    guard let message = message as? AttributeMessage else { return false }
    return reviseOnAttributeChanged(
      message: message,
      affectorItem: affectorItem
    )
  }

  /// If any of the attribute values this modifier relies on is changed, then modification value can be changed as well.
  func reviseOnAttributeChanged(
    message: any AttributeMessage,
    affectorItem: any BaseItemMixinProtocol
  ) -> Bool {
    guard let ship = affectorItem.fit?.ship else { return false }
    if let attributeChanges = message.attributeChanges[ship],
       attributeChanges.contains(AttrId.mass.rawValue)
    {
      return true
    }

    if let attributeChanges = message.attributeChanges[
      affectorItem as! BaseItemMixin
    ],
      attributeChanges.contains(where: {
        $0 == AttrId.speed_factor.rawValue || $0 == AttrId.speed_boost_factor.rawValue
      })
    {
      return true
    }

    return false
  }

}

func makeMassModifier() -> DogmaModifier {
  return DogmaModifier(
    affecteeFilter: .item,
    affecteeDomain: .ship,
    affecteeAtributeId: AttrId.mass.rawValue,
    modOperator: .mod_add,
    aggregateMode: .stack,
    affectorAttrId: AttrId.mass_addition.rawValue
  )
}

func makeSignatureModifier() -> DogmaModifier {
  return DogmaModifier(
    affecteeFilter: .item,
    affecteeDomain: .ship,
    affecteeAtributeId: AttrId.signature_radius.rawValue,
    modOperator: .post_percent,
    aggregateMode: .stack,
    affectorAttrId: AttrId.signature_radius_bonus.rawValue
  )
}
