//
//  DroneBandwidthRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//


class DroneBandwidthRegister: BaseResourceRegisterProtocol {
  static func == (lhs: DroneBandwidthRegister, rhs: DroneBandwidthRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var used: Double {
    var returnValue: Double = 0.0
    for item in self.resourceUsers {
      if let item = item as? any BaseItemMixinProtocol {
        returnValue += item.attributes[.drone_bandwidth_used, default: 0.0]
      }
    }
    return returnValue
  }
  
  var output: Double {
    return self.fit?.ship?.attributes[.drone_bandwidth] ?? 0.0
  }
  
  var resourceUsers: Set<AnyHashable> = []
  
  var users: Set<AnyHashable> {
    self.resourceUsers
  }
  
  weak var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.StatesActivatedLoaded, .StatesDeactivatedLoaded])
  }

  func handleStatesActivatedLoaded(message: StatesActivatedLoaded) {
    guard
      message.item is Drone,
      message.states.contains(.online),
      message.item.typeAttributes.keys.contains(where: { $0 == .drone_bandwidth_used})
    else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  func handleStatesDeactivatedLoaded(message: StatesDeactivatedLoaded) {
    guard
      message.item is Drone,
      message.states.contains(.online) else {
      return
    }
    
    self.resourceUsers.remove(message.item as! AnyHashable)
  }
  
  func notify(message: any Message) {
    switch message {
    case let m as StatesActivatedLoaded:
      handleStatesActivatedLoaded(message: m)
    case let m as StatesDeactivatedLoaded:
      handleStatesDeactivatedLoaded(message: m)
    default: break
    }
  }
  
  
  // Not actually used
  func handleEffectsStarted(message: EffectsStarted) { }
  func handleEffectsStopped(message: EffectsStopped) { }
  
}
