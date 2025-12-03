//
//  DamageDealer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public protocol DamageDealerMixinProtocol: BaseItemMixinProtocol {
  func getVolley(targetResists: ResistProfile?) -> DamageStats?
  func getDps(reload: Bool, targetResists: ResistProfile?) -> DamageStats?
  func getAppliedVolley(targetData: [String: Any]?,targetResists: ResistProfile?) -> DamageStats?
  
  func getAppliedDps(reload: Bool, targetData: [String: Any]?, targetResists: ResistProfile?) -> DamageStats?
}

extension DamageDealerMixinProtocol {
  public func ddEffectIter() -> AnyIterator<DamageDealerEffect>? {
    var effects: [DamageDealerEffect] = []
    var suppressorEffects: [Effect] = []
    /*
     effects = []
     suppressor_effects = []
     for effect in self._type_effects.values():
         if not isinstance(effect, DmgDealerEffect):
             continue
         if effect.id not in self._running_effect_ids:
             continue
         effects.append(effect)
         if effect.suppress_dds:
             suppressor_effects.append(effect)
     # If we have any effects which suppress other effects on this item,
     # we're going to cycle only through them
     if suppressor_effects:
         effects = suppressor_effects
     for effect in effects:
         yield effect
     */
    for effect in self.typeEffects.values {
      if !(effect is DamageDealerEffect) {
        continue
      }
      if !self.runningEffectIds.contains(effect.effectId) {
        continue
      }
      effects.append(effect as! DamageDealerEffect)
    }
    let values = effects
    
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  public func getVolley(targetResists: ResistProfile? = nil) -> DamageStats? {
    var volleys: [DamageStats] = []
    guard let iterator = self.ddEffectIter() else { return nil }
    for effect in iterator {
      let volley = effect.getVolley(for: self)
      
      volleys.append(volley)
    }
    
    return DamageStats.combined(volleys, targetResists: targetResists)
  }
  
  public func getDps(reload: Bool = false, targetResists: ResistProfile? = nil) -> DamageStats? {
    var dpss: [DamageStats] = []
    
    guard let iterator = self.ddEffectIter() else {
      return nil
    }
    
    for effect in iterator {
      let dps = effect.getDps(item: self, reload: reload)
      dpss.append(dps)
    }
    return DamageStats.combined(dpss, targetResists: targetResists)
  }
  
  public func getAppliedVolley(
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
    print("!! getAppliedVolley not implemented")
    return nil
  }
  
  public func getAppliedDps(
    reload: Bool = false,
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
    print("!! getAppliedDPS not implemented")
    return nil
  }
}

class DamageDealerMixin: BaseItemMixin {
  func ddEffectIter() -> AnyIterator<DamageDealerEffect>? { nil }
  
  func getVolley(targetResists: ResistProfile? = nil) -> DamageStats? {
    var volleys: [DamageStats] = []
    guard let iterator = self.ddEffectIter() else { return nil }
    for effect in iterator {
      let volley = effect.getVolley(for: self)
      
      volleys.append(volley)
    }
    
    return DamageStats.combined(volleys, targetResists: targetResists)
  }
  
  func getDps(reload: Bool = false, targetResists: ResistProfile? = nil) -> DamageStats? {
    var dpss: [DamageStats] = []
    
    guard let iterator = self.ddEffectIter() else { return nil }
    
    for effect in iterator {
      let dps = effect.getDps(item: self, reload: reload)
      dpss.append(dps)
    }
    return DamageStats.combined(dpss, targetResists: targetResists)
  }
  
  open func getAppliedVolley(
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
    return nil
  }
  
  open func getAppliedDps(
    reload: Bool = false,
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
    return nil
  }
}
