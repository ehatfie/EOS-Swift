//
//  HardpointEffectRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//


protocol HardpointEffectSlotRegisterProtocol: BaseSlotRegisterProtocol {
  var slotEffectId: EffectId { get }
  var slotAttrId: AttrId { get }
  
  var slotUsers: Set<AnyHashable> { get set }
  
  var used: Int { get }
  var total: Int { get }
}

extension HardpointEffectSlotRegisterProtocol {
  
//  public var used: Int {
//    return slotUsers.count
//  }
//  
//  public var total: Int {
//    return Int(self.fit?.ship?.attributes![self.slotAttrId] ?? 0.0)
//  }
  
}

public class HardpointEffectSlotRegister: HardpointEffectSlotRegisterProtocol {
  public static func == (lhs: HardpointEffectSlotRegister, rhs: HardpointEffectSlotRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  public var slotEffectId: EffectId = .hardpoint_modifier_effect
  public var slotAttrId: AttrId = .hi_slot_modifier
  
  public var slotUsers: Set<AnyHashable> = []
  
  public var users: Set<AnyHashable> {
    return slotUsers
  }
  
  weak public var fit: Fit?
  
  public var used: Int {
    return slotUsers.count
  }
  
  public var total: Int {
    return Int(self.fit?.ship?.attributes![self.slotAttrId.rawValue] ?? 0.0)
  }
  
  public init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    if message.effectIds.contains(slotEffectId.rawValue) {
      self.slotUsers.insert(message.item as! AnyHashable)
    }
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    if !message.effectIds.contains(slotEffectId.rawValue) {
      self.slotUsers.remove(message.item as! AnyHashable)
    }
  }
}

public class TurretSlotRegister: HardpointEffectSlotRegister {
  override public init(fit: Fit) {
    super.init(fit: fit)
    
    self.slotEffectId = .turret_fitted
    self.slotAttrId = .turret_slots_left
  }
}

public class LauncherSlotRegister: HardpointEffectSlotRegister {
  override public init(fit: Fit) {
    super.init(fit: fit)
    
    self.slotEffectId = .launcher_fitted
    self.slotAttrId = .launcher_slots_left
  }
}
