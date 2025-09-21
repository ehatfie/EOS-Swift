//
//  Coordinates.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

/// Container for coordinate data.
class Coordinates {
  var x: CGFloat
  var y: CGFloat
  var z: CGFloat
  
  init(x: CGFloat, y: CGFloat, z: CGFloat) {
    self.x = x
    self.y = y
    self.z = z
  }
}

/// Container for orientation data.
class Orientation: Coordinates {
  override init (x: CGFloat, y: CGFloat, z: CGFloat) {
    super.init(x: x, y: y, z: z)
    // maybe throw if one coordinate isnt 0
    
    if x == y && y == z && z == 0 {
      print("!! at least one value should be not 0")
    }
  }
}
