//
//  DamageDealerEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


class DamageDealerEffect: Effect {
  open func getVolley(for item: any BaseItemMixinProtocol) -> DamageStats {
    return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
  }
  
  func getDps(item: any BaseItemMixinProtocol, reload: Bool) -> DamageStats {
    guard let cycleParameters = self.getCycleParameters(item: item, reload: reload) else {
      return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
    }
    let volley = self.getVolley(for: item)
    let averageTime: Double = 1.0
    
    return DamageStats(
      em: volley.em,
      thermal: volley.thermal,
      kinetic: volley.kinetic,
      explosive: volley.explosive,
      mult: 1 / averageTime
    )!
  }
  
  open func getAppliedVolley(item: any BaseItemMixinProtocol, targetData: [String: Any], reload: Bool) -> DamageStats? {
    return nil
  }
  
  open func getAppliedDps(item: any BaseItemMixinProtocol, targetData: [String: Any], reload: Bool) -> DamageStats? {
    return nil
  }
}
