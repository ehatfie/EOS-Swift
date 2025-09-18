//
//  ChargeGroupRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//

fileprivate let ALLOWED_GROUP_ATTR_IDS = [
  AttrId.charge_group_1,
  AttrId.charge_group_2,
  AttrId.charge_group_3,
  AttrId.charge_group_4,
  AttrId.charge_group_5
]

struct ChargeGroupErrorData {
  let groupId: Int64
  let allowedGroupIds: Set<Int64>
}

// Do not allow to load charges besides those specified by container.
class ChargeGroupRestrictionRegister: BaseRestrictionRegisterProtocol, FitHaving {
  static func == (lhs: ChargeGroupRestrictionRegister, rhs: ChargeGroupRestrictionRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  var fit: Fit
  
  var restrictionType: Restriction = .charge_group
  var restrictedContainers: [AnyHashable: Set<Int64>] = [:]
  
  init(fit: Fit) {
    self.fit = fit
    fit.subscribe(subscriber: self, for: [.ItemLoaded, .ItemUnloaded])
  }
  
  func validate() throws {
    var taintedItems: [AnyHashable: ChargeGroupErrorData] = [:]
    // If item has charge and its group is not allowed, taint charge item (not container)
    for (container, allowedGroupIds) in self.restrictedContainers {
      guard let realContainer = container as? any BaseItemMixinProtocol else { continue }
      guard let module = realContainer as? Module else {
        continue
      }
      
      guard let charge = module.charge else {
        continue
      }
      
      guard let groupId = charge.itemType?.groupId else {
        continue
      }
      
      if !allowedGroupIds.contains(groupId) {
        taintedItems[charge as AnyHashable] = ChargeGroupErrorData(groupId: groupId, allowedGroupIds: allowedGroupIds)
      }
    }
    
    if !taintedItems.isEmpty {
      throw RestrictionValidationError(data: taintedItems)
    }
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
    
    var allowedGroupIds: Set<Int64> = []
    
    for attributeId in ALLOWED_GROUP_ATTR_IDS {
      guard let allowedGroupId = messageItem.attributes[attributeId] else { return }
      allowedGroupIds.insert(Int64(allowedGroupId))
    }
    guard !allowedGroupIds.isEmpty else { return }
    
    self.restrictedContainers[message.item as! AnyHashable] = allowedGroupIds
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    let messageItem = message.item
    
    if self.restrictedContainers[messageItem as! AnyHashable] != nil {
      self.restrictedContainers.removeValue(forKey: messageItem as! AnyHashable)
    }
  }
  
}
