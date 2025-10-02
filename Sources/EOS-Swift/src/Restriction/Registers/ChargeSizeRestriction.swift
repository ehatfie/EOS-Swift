//
//  ChargeSize.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//


struct ChargeSizeErrorData {
  let size: Double
  let allowedSize: Double
}

/// Container and charge must be of matching sizes.
/// Details:
///   If container doesn't specify size, charge always passes validation.
///   If container specifies size and item doesn't specify it, charge is not allowed to be loaded.
///   If container does not specify size, charge of any size can be loaded.
///   To determine allowed size and charge size, item type attributes areused.
class ChargeSizeRestrictionRegister: BaseRestrictionRegisterProtocol {
  static func == (lhs: ChargeSizeRestrictionRegister, rhs: ChargeSizeRestrictionRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var restrictionType: Restriction = .charge_size
  var restrictedContainers: Set<AnyHashable> = []
  
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
    if message.item.typeAttributes[.charge_size] == nil {
      return
    }
    self.restrictedContainers.insert(messageItem as! AnyHashable)
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    let messageItem = message.item
    self.restrictedContainers.remove(messageItem as! AnyHashable)
  }
  
  func validate() throws {
    var taintedItems: [AnyHashable: ChargeSizeErrorData] = [:]
    
    for container in restrictedContainers {
      guard let item = container as? any BaseItemMixinProtocol else { continue }
      guard let charge = item as? Charge, charge.isLoaded else { continue }
      
      let containerSize = item.typeAttributes[.charge_size]
      let chargeSize = charge.typeAttributes[.charge_size]
      
      if containerSize != chargeSize {
        taintedItems[charge as AnyHashable] = ChargeSizeErrorData(size: chargeSize!, allowedSize: containerSize!)
      }
      
    }
    
    if !taintedItems.isEmpty {
      throw RestrictionValidationError(data: taintedItems)
    }
  }
  
}
