//
//  Drone.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

import Foundation

protocol DroneProtocol:
  MutableStateMixin,
  BufferTankingMixinProtocol,
  EffectStatsMixinProtocol,
  SolarSystemItemMixinProtocol,
  SingleTargetableMixinProtocol
{

  
}


class Drone: MutableStateMixin, DroneProtocol {
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
  
  var coordinate: Coordinates
  var orientation: Orientation
  
  var target: (any BaseItemMixinProtocol)?
  
  override init(typeId: Int64, state: StateI = .offline) {
    
    self.coordinate = Coordinates(x: 0, y: 0, z: 0)
    self.orientation = Orientation(x: 1, y: 0, z: 0)
    
    super.init(typeId: typeId, state: state)
    
    modifierDomain = nil
    ownerModifiable = true
    // solsysCarrier = self
  }
  
  
}
