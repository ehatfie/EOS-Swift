//
//  DamageDealer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol DamageDealerMixinProtocol: BaseItemMixinProtocol {
  func getVolley(targetResists: ResistProfile?) -> DamageStats?
  func getDps(reload: Bool, targetResists: ResistProfile?) -> DamageStats?
  func getAppliedVolley(targetData: [String: Any]?,targetResists: ResistProfile?) -> DamageStats?
  
  func getAppliedDps(reload: Bool, targetData: [String: Any]?, targetResists: ResistProfile?) -> DamageStats?
}

extension DamageDealerMixinProtocol {
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
  
  func getAppliedVolley(
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
    return nil
  }
  
  func getAppliedDps(
    reload: Bool = false,
    targetData: [String: Any]? = nil,
    targetResists: ResistProfile? = nil
  ) -> DamageStats? {
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
