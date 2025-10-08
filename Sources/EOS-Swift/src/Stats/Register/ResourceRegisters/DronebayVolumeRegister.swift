//
//  DronebayVolumeRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

public class DronebayVolumeRegister: BaseResourceRegisterProtocol {
  public static func == (lhs: DronebayVolumeRegister, rhs: DronebayVolumeRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  public var used: Double {
    var returnValue: Double = 0.0
    
    for item in self.resourceUsers {
      if let item = item as? any BaseItemMixinProtocol {
        returnValue += item.attributes![.volume, default: 0.0]
      }
    }
    
    return returnValue
  }
  
  public var output: Double {
    return self.fit?.ship?.attributes![.drone_capacity] ?? 0.0
  }
  
  public var resourceUsers: Set<AnyHashable> = []
  
  public var users: Set<AnyHashable> {
    self.resourceUsers
  }
  
  weak public var fit: Fit?

  public init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.ItemLoaded, .ItemUnloaded])
  }
  
  public func handleItemLoaded(message: ItemLoaded) {
    guard message.item is Drone, message.item.typeAttributes.keys.contains(.volume) else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  public func handleItemUnloaded(message: ItemUnloaded) {
    guard message.item is Drone else {
      return
    }
    
    self.resourceUsers.remove(message.item as! AnyHashable)
  }

  public func handleEffectsStarted(message: EffectsStarted) { }
  public func handleEffectsStopped(message: EffectsStopped) { }
}
