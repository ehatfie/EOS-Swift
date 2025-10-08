//
//  Coordinates.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

/// Container for coordinate data.
public class Coordinates {
  public var x: CGFloat
  public var y: CGFloat
  public var z: CGFloat
  
  public init(x: CGFloat, y: CGFloat, z: CGFloat) {
    self.x = x
    self.y = y
    self.z = z
  }
}

/// Container for orientation data.
public class Orientation: Coordinates {
  public override init (x: CGFloat, y: CGFloat, z: CGFloat) {
    super.init(x: x, y: y, z: z)
    // maybe throw if one coordinate isnt 0
    
    if x == y && y == z && z == 0 {
      print("!! at least one value should be not 0")
    }
  }
}
