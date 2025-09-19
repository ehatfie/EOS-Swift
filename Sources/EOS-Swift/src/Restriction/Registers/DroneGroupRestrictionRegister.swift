//
//  DroneGroupRestrictionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//


let ALLOWED_GROUP_ATTR_IDS = [
  AttrId.allowed_drone_group_1,
  AttrId.allowed_drone_group_2
]

struct DroneGroupErrorData {
  let groupId: Int64
  let allowedGroupIds: Int64
}

class DroneGroupRestrictionRegister: BaseRestrictionRegisterProtocol {
  static func == (lhs: DroneGroupRestrictionRegister, rhs: DroneGroupRestrictionRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  var restrictionType: Restriction = .drone_group
  
  var fit: Fit
  var drones: Set<AnyHashable> = []
  
  init(fit: Fit) {
    self.fit = fit
    self.fit.subscribe(subscriber: self, for: [.ItemLoaded, .ItemUnloaded])
  }
  
  func validate() throws {
    // TODO
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
    // TODO
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    // TODO
  }
}
