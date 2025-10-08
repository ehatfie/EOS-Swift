//
//  DroneBandwidthRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//


public class DroneBandwidthRegister: BaseResourceRegisterProtocol {
  public static func == (lhs: DroneBandwidthRegister, rhs: DroneBandwidthRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  public var used: Double {
    var returnValue: Double = 0.0
    for item in self.resourceUsers {
      if let item = item as? any BaseItemMixinProtocol {
        returnValue += item.attributes![.drone_bandwidth_used, default: 0.0]
      }
    }
    return returnValue
  }
  
  public var output: Double {
    return self.fit?.ship?.attributes![.drone_bandwidth] ?? 0.0
  }
  
  public var resourceUsers: Set<AnyHashable> = []
  
  public var users: Set<AnyHashable> {
    self.resourceUsers
  }
  
  weak public var fit: Fit?
  
  public init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.StatesActivatedLoaded, .StatesDeactivatedLoaded])
  }

  public func handleStatesActivatedLoaded(message: StatesActivatedLoaded) {
    guard
      message.item is Drone,
      message.states.contains(.online),
      message.item.typeAttributes.keys.contains(where: { $0 == .drone_bandwidth_used})
    else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  public func handleStatesDeactivatedLoaded(message: StatesDeactivatedLoaded) {
    guard
      message.item is Drone,
      message.states.contains(.online) else {
      return
    }
    
    self.resourceUsers.remove(message.item as! AnyHashable)
  }
  
  public func notify(message: any Message) {
    switch message {
    case let m as StatesActivatedLoaded:
      handleStatesActivatedLoaded(message: m)
    case let m as StatesDeactivatedLoaded:
      handleStatesDeactivatedLoaded(message: m)
    default: break
    }
  }
  
  
  // Not actually used
  public func handleEffectsStarted(message: EffectsStarted) { }
  public func handleEffectsStopped(message: EffectsStopped) { }
  
}
