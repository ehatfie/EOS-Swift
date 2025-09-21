//
//  DronebayVolumeRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

class DronebayVolumeRegister: BaseResourceRegisterProtocol {
  static func == (lhs: DronebayVolumeRegister, rhs: DronebayVolumeRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  var used: Double {
    var returnValue: Double = 0.0
    
    for item in self.resourceUsers {
      if let item = item as? any BaseItemMixinProtocol {
        returnValue += item.attributes[.volume, default: 0.0]
      }
    }
    
    return returnValue
  }
  
  var output: Double {
    return self.fit?.ship?.attributes[.drone_capacity] ?? 0.0
  }
  
  var resourceUsers: Set<AnyHashable> = []
  
  var users: Set<AnyHashable> {
    self.resourceUsers
  }
  
  weak var fit: Fit?

  init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.ItemLoaded, .ItemUnloaded])
  }
  
  func handleItemLoaded(message: ItemLoaded) {
    guard message.item is Drone, message.item.typeAttributes.keys.contains(.volume) else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  func handleItemUnloaded(message: ItemUnloaded) {
    guard message.item is Drone else {
      return
    }
    
    self.resourceUsers.remove(message.item as! AnyHashable)
  }

  func handleEffectsStarted(message: EffectsStarted) { }
  func handleEffectsStopped(message: EffectsStopped) { }
}
