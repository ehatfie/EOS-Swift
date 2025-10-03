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
}

extension HardpointEffectSlotRegisterProtocol {
  
  var used: Int {
    return slotUsers.count
  }
  
  var total: Int {
    return Int(self.fit?.ship?.attributes![self.slotAttrId] ?? 0.0)
  }
  
}

class HardpointEffectSlotRegister: HardpointEffectSlotRegisterProtocol {
  static func == (lhs: HardpointEffectSlotRegister, rhs: HardpointEffectSlotRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var slotEffectId: EffectId = .hardpoint_modifier_effect
  var slotAttrId: AttrId = .hi_slot_modifier
  
  var slotUsers: Set<AnyHashable> = []
  
  var users: Set<AnyHashable> {
    return slotUsers
  }
  
  weak var fit: Fit?
  
  init(fit: Fit) {
    self.fit = fit
    
    self.fit?.subscribe(subscriber: self, for: [.EffectsStarted, .EffectsStopped])
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    if message.effectIds.contains(slotEffectId) {
      self.slotUsers.insert(message.item as! AnyHashable)
    }
  }
  
  func handleEffectsStopped(message: EffectsStopped) {
    if !message.effectIds.contains(slotEffectId) {
      self.slotUsers.remove(message.item as! AnyHashable)
    }
  }
}

class TurretSlotRegister: HardpointEffectSlotRegister {
  override init(fit: Fit) {
    super.init(fit: fit)
    
    self.slotEffectId = .turret_fitted
    self.slotAttrId = .turret_slots_left
  }
}

class LauncherSlotRegister: HardpointEffectSlotRegister {
  override init(fit: Fit) {
    super.init(fit: fit)
    
    self.slotEffectId = .launcher_fitted
    self.slotAttrId = .launcher_slots_left
  }
}
