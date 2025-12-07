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
  SingleTargetableMixinProtocol,
  ItemContainerBaseProtocol
{

  var chargeQuantity: Double? { get }
  var cyclesUntilReload: Double? { get }
  var reloadTime: Double? { get }
  var reactivationDelay: Double? { get }

  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>
}

public class Module:
  MutableStateMixin,
  EffectStatsMixinProtocol,
  BaseTargetableMixinProtocol,
  SingleTargetableMixinProtocol,
  ModuleProtocol
{
  
  public func subItemIterator(item: BaseItemMixin) -> AnyIterator<any BaseItemMixinProtocol> {
    return self.subItemIterator(item: item as! BaseItemMixin) as! AnyIterator<any BaseItemMixinProtocol>
  }
  
  public typealias ExpectedType = BaseItemMixin
  
  public func checkClass(item: (any BaseItemMixinProtocol)?, allowNil: Bool) -> Bool {
    return true
  }
  
  public func length() -> Int {
    return Int(chargeQuantity ?? 0)
  }
  
  var target: (any BaseItemMixinProtocol)?
  
  public var charge: ItemDescriptor<Charge>
  /*
   Max quantity of loadable charges.
  
   It depends on capacity of this item and volume of charge.
  
   Returns:
      Quantity of loadable charges as integer. If any of necessary
      attribute values is not defined, or no charge is found in item, None
      is returned.
   */
  public var chargeQuantity: Double? {
    guard let charge = charge.get() else { return nil }
    
    guard
      let attributes = charge.attributes,
      let containerCapacity = self.attributes![AttrId.capacity.rawValue],
          let chargeVolume = attributes[AttrId.volume.rawValue]
    else {
      return nil
    }
    self.itemType
    print("++ containerCapacity \(containerCapacity) chargeVolume \(chargeVolume)")
    print("++ \(self.typeId)(our) attributes \(self.attributes?.keys ?? [-1]), charge attributes \(charge.attributes?.keys ?? [-1])")
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
    guard let timeMs = self.attributes![AttrId.reload_time.rawValue] else {
      return nil
    }
    return timeMs / 1000
  }

  var reactivationDelay: Double? {
    guard
      let delayMs = self.attributes![AttrId.module_reactivation_delay.rawValue]
    else {
      return nil
    }

    return delayMs / 1000
  }

  public var cycleTime: Double? {
    self.safeGetFromDefeff(key: "get_duration")
  }
  
  public var optimalRange: Double? {
    self.safeGetFromDefeff(key: "get_optimal_range")
  }
  
  public var falloffRange: Double? {
    self.safeGetFromDefeff(key: "get_falloff_range")
  }
  
  public var trackingSpeed: Double? {
    self.safeGetFromDefeff(key: "get_tracking_speed")
  }

  public init(typeId: Int64, state: StateI = .offline, charge: Charge? = nil) {
    self.charge = ItemDescriptor<Charge>()
    
    super.init(typeId: typeId, state: state)
    if let charge = charge {
      do {
        print("++ pre-charge set \(charge.typeId)")
        try self.charge.set(item: charge, parent: self)
      } catch let error {
        print("++ module init set charge error \(error)")
      }
      
    }
    
    self.ownerModifiable = false
    self.modifierDomain = .ship
  }
  

  
  func safeGetFromDefeff(key: String) -> Double? {
    let defaultEffect = self.typeDefaultEffect
    if let effect = defaultEffect as? Effect {
      switch key {
      case "get_duration": return effect.getDuration(item: self)
      case "get_optimal_range": return effect.getOptimalRange(item: self)
      case "get_falloff_range": return effect.getFalloffRange(item: self)
      case "get_tracking_speed": return effect.getTrackingSpeed(item: self)
      default: return nil
      }
    } else {
      print("couldnt convert \(defaultEffect)")
    }
    return nil
  }
  
//  public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>? {
//    print("++ module childItemIterator")
//    let charge = self.charge.item
//    let foo: AnyIterator<any BaseItemMixinProtocol>? = super.childItemIterator(skipAutoItems: false)//.map { $0.next()}
//    let bar: [(any BaseItemMixinProtocol)?] = foo?.map { $0 } ?? []
//    let values: [(any BaseItemMixinProtocol)?] = [charge] + bar
//    var index: Int = 0
//    print("++ module childItemIterator value count \(values.count) with \(values)")
//    return AnyIterator {
//      guard index < values.count else { return nil }
//      defer { index += 1 }
//      return values[index]
//    }
//  }
  //public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol> {
  // duplicate?? Pretty sure the above is the right way to do it
  override public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol> {
    print("++ module childItemIterator2")
    let charge = self.charge.item
    let foo: AnyIterator<any BaseItemMixinProtocol>? = super.childItemIterator(skipAutoItems: false)//.map { $0.next()}
    let bar: [(any BaseItemMixinProtocol)?] = foo?.map { $0 } ?? []
    let values: [(any BaseItemMixinProtocol)?] = [charge] + bar
    var index: Int = 0
    print("++ module childItemIterator2 value count \(values.count)")
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  override func addAutoCharge(effectId: Int64, autoChargeTypeId: Int64) {
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
