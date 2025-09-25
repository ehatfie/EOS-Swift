//
//  CapitalItemRestriction.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//

fileprivate let MAX_SUBCAP_VOLUME: Double = 3500

class CapitalItemRestrictionRegister: BaseRestrictionRegisterProtocol {
  var fit: Fit
  
  let trackedClasses: [any BaseItemMixinProtocol.Type] = [
    ModuleHigh.self, ModuleLow.self, ModuleMid.self
  ]
  
  func notify(message: any Message) {
    switch message {
    case let m as ItemLoaded:
      handleItemLoaded(message: m)
    case let m as ItemUnloaded:
      handleItemUnloaded(message: m)
    default: break
    }
  }

  var restrictionType: Restriction
  var capitalItems: Set<AnyHashable> = []
  
  static func == (lhs: CapitalItemRestrictionRegister, rhs: CapitalItemRestrictionRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  init(fit: Fit) {
    print("++ CapitalItemRestrictionRegister init")
    self.fit = fit
    self.restrictionType = .capital_item
    fit.subscribe(subscriber: self, for: [MessageTypeEnum.ItemLoaded, .ItemUnloaded])
  }
  
  func handleItemLoaded(message: ItemLoaded) {
    let item = message.item
    let itemType = item.self
    
    guard trackedClasses.contains(where: { type(of: item) == $0 }) else { return }
    guard let itemVolume = message.item.typeAttributes[.volume] else {
      return
    }
    guard itemVolume >= MAX_SUBCAP_VOLUME else {
      return
    }
    
    self.capitalItems.insert(itemType as! AnyHashable)
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    capitalItems.remove(message.item as! AnyHashable)
  }
  
  func validate() throws {
    guard let ship = self.fit.ship else { return }
    guard ship.typeAttributes[.is_capital_size] == nil else {
      return
    }
    
    // If we got here, then we're dealing with non-capital ship, and all registered items are tainted
    if !self.capitalItems.isEmpty {
      var taintedItems: [AnyHashable: CapitalItemErrorData] = [:]
      let items = Array(self.capitalItems).compactMap { $0 as? any BaseItemMixinProtocol }
      
      for item in items {
        let itemTypeVolume = item.typeAttributes[.volume, default: 0.0]
        taintedItems[item as! AnyHashable] = CapitalItemErrorData(itemVolume: itemTypeVolume, maxSubcapVolume: MAX_SUBCAP_VOLUME)
      }
      throw RestrictionValidationError(data: taintedItems)
    }
  }
  
}

struct CapitalItemErrorData {
  let itemVolume: Double
  let maxSubcapVolume: Double
}
