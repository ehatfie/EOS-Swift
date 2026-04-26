//
//  DamageDealerEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol DamageDealerEffectProtocol: Effect {
  var suppressesDD: Bool { get }
  
  func getVolley(for item: any BaseItemMixinProtocol) -> DamageStats
  func getDps(item: any BaseItemMixinProtocol, reload: Bool) -> DamageStats
  func getAppliedVolley(item: any BaseItemMixinProtocol, targetData: Any, reload: Bool) -> DamageStats?
  func getAppliedDps(item: any BaseItemMixinProtocol, targetData: Any, reload: Bool) -> DamageStats?
}

extension DamageDealerEffectProtocol {
  func getVolley(for item: any BaseItemMixinProtocol) -> DamageStats {
    return .empty
  }
  
  func getDps(item: any BaseItemMixinProtocol, reload: Bool) -> DamageStats {
    guard let cycleParameters = self.getCycleParameters(item: item, reload: reload) else {
      return .empty
    }
    let volley = self.getVolley(for: item)
    guard let averageTime: Double = cycleParameters.0?.averageTime ?? cycleParameters.1?.getTime() else {
      print("!! getDPS extension no cycle time")
      return .empty
    }
    
    return DamageStats(
      em: volley.em,
      thermal: volley.thermal,
      kinetic: volley.kinetic,
      explosive: volley.explosive,
      mult: 1 / averageTime
    )!
  }
  
  func getAppliedVolley(item: any BaseItemMixinProtocol, targetData: Any, reload: Bool) -> DamageStats? {
    return nil
  }
  
  func getAppliedDps(item: any BaseItemMixinProtocol, targetData: Any, reload: Bool) -> DamageStats? {
    return nil
  }
}

public class DamageDealerEffect: Effect {
  var suppressesDD: Bool = false
  open func getVolley(for item: any BaseItemMixinProtocol) -> DamageStats {
    return .empty
  }
  
  public func getDps(item: any BaseItemMixinProtocol, reload: Bool) -> DamageStats {
    guard let cycleParameters = self.getCycleParameters(item: item, reload: reload) else {
      return .empty
    }
    
    let volley = self.getVolley(for: item)
    guard let averageTime: Double = cycleParameters.0?.averageTime ?? cycleParameters.1?.getTime() else {
      print("!! getDPS no cycle time")
      return .empty
    }
    
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
