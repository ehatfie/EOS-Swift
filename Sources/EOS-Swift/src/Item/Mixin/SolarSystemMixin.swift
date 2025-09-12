//
//  SolarSystem.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//
import Foundation

struct Coordinates {
  var x: CGFloat
  var y: CGFloat
  var z: CGFloat
}

protocol SolarSystemMixinProtocol {
  var coordinate: CGSize { get set }
  var orientation: CGSize { get set }
}

class SolarSystemMixin {
  let coordinate: CGSize
  let orientation: CGSize
  
  init(coordinate: CGSize, orientation: CGSize) {
    self.coordinate = coordinate
    self.orientation = orientation
  }
}
