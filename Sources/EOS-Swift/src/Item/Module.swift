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

public class Module:
  MutableStateMixin,
  EffectStatsMixinProtocol,
  BaseTargetableMixinProtocol,
  SingleTargetableMixinProtocol,
  ModuleProtocol
{

  
  var target: (any BaseItemMixinProtocol)?
  
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

  var cycleTime: Double = 0

  func safeGetFromDefeff(key: String) {

  }

  public init(typeId: Int64, state: StateI = .offline, charge: Charge? = nil) {
    self.charge = charge
    super.init(typeId: typeId, state: state)

    self.ownerModifiable = false
    self.modifierDomain = .ship
  }
  
  override public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>? {
    let foo: AnyIterator<any BaseItemMixinProtocol>? = super.childItemIterator(skipAutoItems: false)//.map { $0.next()}
    let bar: [(any BaseItemMixinProtocol)?] = foo?.map { $0 } ?? []
    let values: [(any BaseItemMixinProtocol)?] = [charge] + bar
    var index: Int = 0

    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  // duplicate?? Pretty sure the above is the right way to do it
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
  }
  
  override func addAutoCharge(effectId: EffectId, autoChargeTypeId: Int64) {
    if self.autocharges == nil {
      self.autocharges = ItemDict<AutoCharge>(parent: self, containerOverride: self)
    }
    
    self.autocharges?.setItem(
      key: effectId as AnyHashable,
      item: AutoCharge(typeId: autoChargeTypeId)
    )
  }

}

public class ModuleHigh: Module {
  
}

public class ModuleMid: Module {

}

public class ModuleLow: Module {

}
