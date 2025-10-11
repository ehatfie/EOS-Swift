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
      affecteeAtributeId: .max_velocity
    )
  }

  override func getModification(affectorItem: any BaseItemMixinProtocol)
    -> GetModResponse?
  {
    guard let ship = affectorItem.fit?.ship else { return nil }

    /// If attribute values of any necessary items are not available, do not calculate anything
    guard
      let mass = ship.attributes?[.mass],
      let speedBoost = ship.attributes?[.speed_factor],
      let thrust = ship.attributes?[.speed_boost_factor]
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
      attributeChanges.contains(.mass)
    {
      return true
    }

    if let attributeChanges = message.attributeChanges[
      affectorItem as! BaseItemMixin
    ],
      attributeChanges.contains(where: {
        $0 == .speed_factor || $0 == .speed_boost_factor
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
    affecteeAtributeId: .mass,
    modOperator: .mod_add,
    aggregateMode: .stack,
    affectorAttrId: .mass_addition
  )
}

func makeSignatureModifier() -> DogmaModifier {
  return DogmaModifier(
    affecteeFilter: .item,
    affecteeDomain: .ship,
    affecteeAtributeId: .signature_radius,
    modOperator: .post_percent,
    aggregateMode: .stack,
    affectorAttrId: .signature_radius_bonus
  )
}
