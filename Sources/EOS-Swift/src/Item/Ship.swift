//
//  Ship.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//
import Foundation

// Might be worth sticking to the BaseItemMixin implementation
public class Ship:
  BaseItemMixin,
  ImmutableStateMixinProtocol,
  BufferTankingMixinProtocol,
  SolarSystemItemMixinProtocol
{
  
  public var coordinate: Coordinates = Coordinates(x: 0, y: 0, z: 0)
  public var orientation: Orientation = Orientation(x: 1, y: 0, z: 0)

  public override init(typeId: Int64, state: StateI = .offline) {
    super.init(typeId: typeId, state: state)
    self.modifierDomain = .ship
    self.ownerModifiable = true
  }
}

//extension Ship: BufferTankingMixin {
//  
//}
//
//extension Ship: SolarSystemMixin {
//  
//}
