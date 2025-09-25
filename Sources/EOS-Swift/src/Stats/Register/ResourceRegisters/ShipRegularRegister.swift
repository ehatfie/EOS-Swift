//
//  ShipRegularRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

protocol ShipRegularResourceRegisterProtocol: BaseResourceRegisterProtocol, EffectsSubscriberProtocol {
  var outputAttrId: AttrId { get }
  var useEffectId: EffectId { get }
  var useAttrId: AttrId { get }
  
  var resourceUsers: Set<AnyHashable> { get set }
}

extension ShipRegularResourceRegisterProtocol {
  var used: Double {
    var returnValue: Double = 0.0
    for item in self.resourceUsers {
      guard let foo = item as? any BaseItemMixinProtocol else {
        continue
      }
      
      returnValue += foo.attributes[self.useAttrId, default: 0.0]
    }
    return returnValue
  }
  
  var output: Double {
    return self.fit?.ship?.attributes[self.outputAttrId] ?? 0.0
  }
  
  var users: Set<AnyHashable> {
    return self.resourceUsers
  }
}

protocol RoundedShipRegularResourceRegisterProtocol: ShipRegularResourceRegisterProtocol, Equatable {
  
}

extension RoundedShipRegularResourceRegisterProtocol {
  var used: Double {
    round(used)
  }
}

class CalibrationRegister: ShipRegularResourceRegisterProtocol {
  static func == (lhs: CalibrationRegister, rhs: CalibrationRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  var outputAttrId: AttrId = .upgrade_capacity
  var useEffectId: EffectId = .rig_slot
  var useAttrId: AttrId = .upgrade_cost
  
  var resourceUsers: Set<AnyHashable> = []
  
  weak var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    let foo =  message.effectIds.contains(self.useEffectId)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    
    guard foo && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  func handleEffectsStopped(message: EffectsStopped) {
    if message.effectIds.contains(self.useEffectId) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}

class CPURegister: RoundedShipRegularResourceRegisterProtocol {
  static func == (lhs: CPURegister, rhs: CPURegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var outputAttrId: AttrId = .cpu_output
  var useEffectId: EffectId = .online
  var useAttrId: AttrId = .cpu
  
  var resourceUsers: Set<AnyHashable> = []
  
  weak var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  func handleEffectsStopped(message: EffectsStopped) {
    let foo =  message.effectIds.contains(self.useEffectId)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    
    guard foo && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    if message.effectIds.contains(self.useEffectId) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}

class PowergridRegister: RoundedShipRegularResourceRegisterProtocol {
  static func == (lhs: PowergridRegister, rhs: PowergridRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var outputAttrId: AttrId = .power_output
  var useEffectId: EffectId = .online
  var useAttrId: AttrId = .power
  
  var resourceUsers: Set<AnyHashable> = []

  weak var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  func handleEffectsStopped(message: EffectsStopped) {
    let foo =  message.effectIds.contains(self.useEffectId)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    
    guard foo && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    if message.effectIds.contains(self.useEffectId) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}
