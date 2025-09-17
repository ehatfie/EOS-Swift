//
//  Module.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

protocol EffectStatsMixinProtocol:
  DefaultEffectProxyMixinProtocol,
  CapTransmitMixinProtocol,
  DamageDealerMixinProtocol,
  NeutMixinProtocol,
  RemoteRepairMixinProtocol
{}

protocol ModuleProtocol:
  MutableStateMixin,
  EffectStatsMixinProtocol,
  BaseTargetableMixinProtocol,
  SingleTargetableMixinProtocol
{

  var chargeQuantity: Double? { get }
  var cyclesUntilReload: Double? { get }
  var reloadTime: Double? { get }
  var reactivationDelay: Double? { get }

  func childItemIterator() -> AnyIterator<any BaseItemMixinProtocol>
}

class Module:
  MutableStateMixin,
  EffectStatsMixinProtocol,
  BaseTargetableMixinProtocol,
  SingleTargetableMixinProtocol,
  ModuleProtocol
{

  
  var charge: Charge?
  /*
   Max quantity of loadable charges.
  
   It depends on capacity of this item and volume of charge.
  
   Returns:
      Quantity of loadable charges as integer. If any of necessary
      attribute values is not defined, or no charge is found in item, None
      is returned.
   */
  var chargeQuantity: Double? {
    guard let charge = charge else { return nil }

    guard let containerCapacity = self.attributes[AttrId.capacity],
      let chargeVolume = self.attributes[AttrId.volume]
    else {
      return nil
    }
    let chargeQuantity = Double(containerCapacity / chargeVolume)
    return chargeQuantity
  }

  /*
   Quantity of cycles item can run until charges are depleted.
  
   Relays calculation to effect, because final value depends on effect type.
   */
  var cyclesUntilReload: Double? {
    guard let itemType = self.itemType else {
      return nil
    }

    return itemType.defaultEffect?.getCyclesUntilReload(item: self)
  }

  var reloadTime: Double? {
    guard let timeMs = self.attributes[AttrId.reload_time] else {
      return nil
    }
    return timeMs / 1000
  }

  var reactivationDelay: Double? {
    guard
      let delayMs = self.attributes[AttrId.module_reactivation_delay]
    else {
      return nil
    }

    return delayMs / 1000
  }

  var target: Any?

  var cycleTime: Double = 0

  func safeGetFromDefeff(key: String) {

  }

  init(typeId: Int64, state: State = .offline, charge: Charge?) {
    self.charge = charge
    super.init(typeId: typeId, state: state)

    self.ownerModifiable = false
    self.modifierDomain = .ship
  }

  func getEffectTarget(effectIds: [EffectId]) -> [(EffectId, [any BaseItemMixinProtocol])]? {
    // TODO
    return nil
  }

  func childItemIterator() -> AnyIterator<any BaseItemMixinProtocol> {
    
    let foo: AnyIterator<any BaseItemMixinProtocol>? = super.childItemIterator(skipAutoItems: false)//.map { $0.next()}
    let bar: [(any BaseItemMixinProtocol)?] = foo?.map { $0 } ?? []
    let values: [(any BaseItemMixinProtocol)?] = [charge] + bar
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
    
    
/*
 charge = self.charge
 if charge is not None:
     yield charge
 # Try next in MRO
 try:
     child_item_iter = super()._child_item_iter
 except AttributeError:
     pass
 else:
     for item in child_item_iter(**kwargs):
         yield item
 */
  }
}

class ModuleHigh: Module {

}

class ModuleMid: Module {

}

class ModuleLow: Module {

}
