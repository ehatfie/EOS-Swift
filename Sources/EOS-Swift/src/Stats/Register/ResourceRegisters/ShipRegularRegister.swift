//
//  ShipRegularRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

public protocol ShipRegularResourceRegisterProtocol: BaseResourceRegisterProtocol, EffectsSubscriberProtocol {
  var outputAttrId: AttrId { get }
  var useEffectId: EffectId { get }
  var useAttrId: AttrId { get }
  var usedI: Double { get }
  
  var resourceUsers: Set<AnyHashable> { get set }
}

extension ShipRegularResourceRegisterProtocol {
  public var usedI: Double {
    //print("++ ShipRegularResourceRegisterProtocol used")
    var returnValue: Double = 0.0
    for item in self.resourceUsers {
      guard let foo = item as? any BaseItemMixinProtocol else {
        continue
      }
      
      returnValue += foo.attributes![self.useAttrId, default: 0.0]
    }
    return returnValue
  }
  
  public var used: Double {
    return usedI
  }
  
  public var output: Double {
    //print("++ ShipRegularResourceRegisterProtocol output")
    let val = self.fit?.ship?.attributes![self.outputAttrId] ?? 0.0
    //print("++ ShipRegularResourceRegisterProtocol output return")
    return val
  }
  
  public var users: Set<AnyHashable> {
    return self.resourceUsers
  }
}

public protocol RoundedShipRegularResourceRegisterProtocol: ShipRegularResourceRegisterProtocol, Equatable {
  
}

public extension RoundedShipRegularResourceRegisterProtocol {  
  public var used: Double {
    round(usedI)
  }
}

public class CalibrationRegister: ShipRegularResourceRegisterProtocol {
  public static func == (lhs: CalibrationRegister, rhs: CalibrationRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  public var outputAttrId: AttrId = .upgrade_capacity
  public var useEffectId: EffectId = .rig_slot
  public var useAttrId: AttrId = .upgrade_cost
  
  public var resourceUsers: Set<AnyHashable> = []
  
  weak public var fit: Fit?
  
  public init(fit: Fit) {
    self.fit = fit
    
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let foo =  message.effectIds.contains(self.useEffectId.rawValue)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    
    guard foo && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    if message.effectIds.contains(self.useEffectId.rawValue) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}

public class CPURegister: RoundedShipRegularResourceRegisterProtocol {
  public static func == (lhs: CPURegister, rhs: CPURegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  public var outputAttrId: AttrId = .cpu_output
  public var useEffectId: EffectId = .online
  public var useAttrId: AttrId = .cpu
  
  public var resourceUsers: Set<AnyHashable> = []
  
  weak public var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let isOnline =  message.effectIds.contains(self.useEffectId.rawValue)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    print("&& handleEffectsStarted \(message.item.typeId) \(message.item.itemType?.name) \(isOnline) \(bar)")
    guard isOnline && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
    print("++ ShipRegularRegister handleEffectsStarted resource users \(resourceUsers.count)")
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    
    if message.effectIds.contains(self.useEffectId.rawValue) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}

public class PowergridRegister: RoundedShipRegularResourceRegisterProtocol {
  public static func == (lhs: PowergridRegister, rhs: PowergridRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  public var outputAttrId: AttrId = .power_output
  public var useEffectId: EffectId = .online
  public var useAttrId: AttrId = .power
  
  public var resourceUsers: Set<AnyHashable> = []

  weak public var fit: Fit?
  
  public init(fit: Fit) {
    self.fit = fit
    fit.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let foo =  message.effectIds.contains(self.useEffectId.rawValue)
    let bar = message.item.typeAttributes.keys.contains(where: { $0 == self.useAttrId })
    
    guard foo && bar else {
      return
    }
    self.resourceUsers.insert(message.item as! AnyHashable)
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    if message.effectIds.contains(self.useEffectId.rawValue) {
      self.resourceUsers.remove(message.item as! AnyHashable)
    }
  }
}
