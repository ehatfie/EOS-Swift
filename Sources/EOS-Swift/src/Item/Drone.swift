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
  var coordinate: Coordinates
  var orientation: Orientation
  
  var target: (any BaseItemMixinProtocol)?
  
  var cycleTime: Double = 0.0
  
  func safeGetFromDefeff(key: String) {
  
  }
  
  override init(typeId: Int64, state: StateI = .offline) {
    
    self.coordinate = Coordinates(x: 0, y: 0, z: 0)
    self.orientation = Orientation(x: 1, y: 0, z: 0)
    
    super.init(typeId: typeId, state: state)
    
    modifierDomain = nil
    ownerModifiable = true
    // solsysCarrier = self
  }
  
  
}
