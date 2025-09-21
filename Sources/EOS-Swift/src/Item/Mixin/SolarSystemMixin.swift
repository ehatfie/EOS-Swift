//
//  SolarSystem.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//
import Foundation



protocol SolarSystemItemMixinProtocol {
  var coordinate: Coordinates { get set }
  var orientation: Orientation { get set }
}

class SolarSystemItemMixin {
  let coordinate: Coordinates
  let orientation: Orientation
  
  init() {
    self.coordinate = Coordinates(x: 0, y: 0, z: 0)
    self.orientation = Orientation(x: 1, y: 0, z: 0)
  }
}
