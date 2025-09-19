//
//  ChargeSize.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//


struct ChargeVolumeErrorData {
  let size: Double
  let maxAllowedVolume: Double
}

/// Volume of charge loaded into container should not excess its capacity.
class ChargeVolumeRestrictionRegister: BaseRestrictionRegisterProtocol {
  static func == (lhs: ChargeVolumeRestrictionRegister, rhs: ChargeVolumeRestrictionRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  var restrictionType: Restriction = .charge_volume
  var containers: Set<AnyHashable> = []
  
  var fit: Fit
  
  init(fit: Fit) {
    self.fit = fit
    self.fit.subscribe(subscriber: self, for: [.ItemLoaded, .ItemUnloaded])
  }
  
  func notify(message: any Message) {
    switch message {
    case let m as ItemLoaded:
      handleItemLoaded(message: m)
    case let m as ItemUnloaded:
      handleItemUnloaded(message: m)
    default: break
    }
  }
  
  func handleItemLoaded(message: ItemLoaded) {
    let messageItem = message.item
    if !(messageItem is Charge) { return }
    self.containers.insert(messageItem as! AnyHashable)
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    let messageItem = message.item
    self.containers.remove(messageItem as! AnyHashable)
  }
  
  func validate() throws {
    var taintedItems: [AnyHashable: ChargeVolumeErrorData] = [:]
    
    for container in containers {
      guard let item = container as? any BaseItemMixinProtocol else { continue }
      guard let charge = item as? Charge, charge.isLoaded else { continue }
      // Get volume and capacity with 0 as fallback, and compare them, raising error when charge can't fit
      let chargeVolume = charge.typeAttributes[.volume, default: 0.0]
      let containerCapacity = item.typeAttributes[.capacity, default: 0.0]
      
      if chargeVolume > containerCapacity {
        taintedItems[charge as AnyHashable] = ChargeVolumeErrorData(size: chargeVolume, maxAllowedVolume: containerCapacity)
      }
    }
    
    if !taintedItems.isEmpty {
      throw RestrictionValidationError(data: taintedItems)
    }
  }
  
}
