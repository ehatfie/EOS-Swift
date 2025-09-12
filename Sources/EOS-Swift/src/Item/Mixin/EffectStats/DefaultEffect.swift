//
//  DefaultEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol DefaultEffectProxyMixinProtocol: BaseItemMixinProtocol {
  var cycleTime: Double { get }
  func safeGetFromDefeff(key: String)
}
class DefaultEffectProxyMixin: BaseItemMixin {
  var cycleTime: Double? {
    self.safeGetFromDefeff(key: "get_duration")
  }
  
  func safeGetFromDefeff(key: String) -> Double? {
    let defaultEffect = self.typeDefaultEffect
    if let effect = defaultEffect as? Effect {
      switch key {
      case "get_duration": return effect.getDuration(item: self)
      case "get_optimal_range": return effect.getOptimalRange(item: self)
      case "get_falloff_range": return effect.getFalloffRange(item: self)
      case "get_tracking_speed": return effect.getTrackingSpeed(item: self)
      default: return nil
      }
    }
    return nil
  }
}
