//
//  DefaultEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

/*
 @property
    def optimal_range(self):
        return self.__safe_get_from_defeff('get_optimal_range')

    @property
    def falloff_range(self):
        return self.__safe_get_from_defeff('get_falloff_range')

    @property
    def tracking_speed(self):
        return self.__safe_get_from_defeff('get_tracking_speed')

    def __safe_get_from_defeff(self, method):
        default_effect = self._type_default_effect
        if default_effect is None:
            return None
        return getattr(default_effect, method)(self)

 */

protocol DefaultEffectProxyMixinProtocol: BaseItemMixinProtocol {
  var cycleTime: Double? { get }
  var optimalRange: Double? { get }
  var falloffRange: Double? { get }
  var trackingSpeed: Double? { get }
  
  func safeGetFromDefeff(key: String) -> Double?
}

class DefaultEffectProxyMixin: BaseItemMixin {
  var cycleTime: Double? {
    self.safeGetFromDefeff(key: "get_duration")
  }
  
  var optimalRange: Double? {
    self.safeGetFromDefeff(key: "get_optimal_range")
  }
  
  var falloffRange: Double? {
    self.safeGetFromDefeff(key: "get_falloff_range")
  }
  
  var trackingSpeed: Double? {
    self.safeGetFromDefeff(key: "get_tracking_speed")
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
