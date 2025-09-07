//
//  TankingLayers.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol TankingLayersProtocol<Hashable> {
  associatedtype Hashable
  var hull: Hashable { get set }
  var armor: Hashable { get set }
  var shield: Hashable { get set }
}

class TankingLayers<T: Hashable>: TankingLayersProtocol {
  var hull: T
  var armor: T
  var shield: T
  
  init(hull: T, armor: T, shield: T) {
    self.hull = hull
    self.armor = armor
    self.shield = shield
  }
  
  func makeIterator() -> AnyIterator<T> {
    var index = 0
    let values = [hull, armor, shield]
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  static func == (lhs: TankingLayers, rhs: TankingLayers) -> Bool {
    return lhs.hull == rhs.hull && lhs.armor == rhs.armor && lhs.shield == rhs.shield
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
    hasher.combine(hull)
    hasher.combine(armor)
    hasher.combine(shield)
  }
}

class ItemHP: TankingLayers<Double> {
  var total: Double {
    return self.hull + self.armor + self.shield
  }
  
  override func makeIterator() -> AnyIterator<Double> {
    var index = 0
    let values = [hull, armor, shield, total]
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
}
