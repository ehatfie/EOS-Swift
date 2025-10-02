//
//  DamageTypes.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

/// A container for damage type values.
protocol DamageTypeContainer {
  var em: Double { get }
  var thermal: Double { get }
  var kinetic: Double { get }
  var explosive: Double { get }

  func makeIterator() -> AnyIterator<Double>
  static func == (lhs: Self, rhs: Self) -> Bool
  func hash(into hasher: inout Hasher)
  func description() -> String
}

/// Container for damage data stats.
public class DamageTypes: DamageTypeContainer, Hashable {
  var em: Double
  var thermal: Double
  var kinetic: Double
  var explosive: Double

  init(
    em: Double,
    thermal: Double,
    kinetic: Double,
    explosive: Double
  ) {
    self.em = em
    self.thermal = thermal
    self.kinetic = kinetic
    self.explosive = explosive
  }

  open func makeIterator() -> AnyIterator<Double> {
    var index = 0
    let values = [em, thermal, kinetic, explosive]
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }

  // MARK: - Equality & Hashing
  public static func == (lhs: DamageTypes, rhs: DamageTypes) -> Bool {
    lhs.em == rhs.em && lhs.thermal == rhs.thermal && lhs.kinetic == rhs.kinetic
      && lhs.explosive == rhs.explosive
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
    hasher.combine(em)
    hasher.combine(thermal)
    hasher.combine(kinetic)
    hasher.combine(explosive)
  }

  // MARK: - Description (repr-like)
  func description() -> String {
    return
      "DmgTypes(em=\(em), thermal=\(thermal), kinetic=\(kinetic), explosive=\(explosive))"
  }
}

public class DamageTypesTotal: DamageTypes {
  var total: Double {
    return self.em + self.thermal + self.kinetic + self.explosive
  }

  public override func makeIterator() -> AnyIterator<Double> {
    var index = 0
    let values: [Double] = [
      self.em, self.thermal, self.kinetic, self.explosive, self.total,
    ]
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
}

public class DamageStats: DamageTypesTotal {
  init?(
    em: Double,
    thermal: Double,
    kinetic: Double,
    explosive: Double,
    mult: Double? = nil
  ) {
    var em = em, thermal = thermal, kinetic = kinetic, explosive = explosive
    if let mult = mult {
      em *= mult
      thermal *= mult
      kinetic *= mult
      explosive *= mult
    }
    
    guard em >= 0, thermal >= 0, kinetic >= 0, explosive >= 0 else {
      return nil
    }
    
    super.init(em: em, thermal: thermal, kinetic: kinetic, explosive: explosive)
  }
  
  // I think the idea with this is any parent class that implements DamageStats should be able to use this combined function to create a new object of the class that calls it
  static func combined(
    _ stats: [any DamageTypeContainer],
    targetResists: (any DamageTypeContainer)? = nil
  ) -> DamageStats? {
    guard !stats.isEmpty else { return nil }
    var em: Double = 0
    var therm: Double = 0
    var kin: Double = 0
    var explosive: Double = 0
    
    for stat in stats {
      em += stat.em
      therm += stat.thermal
      kin += stat.kinetic
      explosive += stat.explosive
    }
    
    if let targetResists {
      em *= 1 - targetResists.em
      therm *= 1 - targetResists.thermal
      kin *= 1 - targetResists.kinetic
      explosive *= 1 - targetResists.explosive
      
      
    }
    
    return DamageStats(em: em, thermal: therm, kinetic: kin, explosive: explosive)
//    return DamageStats(
//      em: stats.reduce(0) { $0 + $1.em },
//      thermal: stats.reduce(0) { $0 + $1.thermal },
//      kinetic: stats.reduce(0) { $0 + $1.kinetic },
  }
}


public class DamageProfile: DamageTypes {
  init?(_ em: Double, thermal: Double, kinetic: Double, explosive: Double) {
    guard em >= 0, thermal >= 0, kinetic >= 0, explosive >= 0,
      em + thermal + kinetic + explosive > 0
    else {
      return nil
    }
    
    super.init(em: em, thermal: thermal, kinetic: kinetic, explosive: explosive)
  }
}

public class ResistProfile: DamageTypes {
  init?(_ em: Double, thermal: Double, kinetic: Double, explosive: Double) {
    guard
      (em >= 0 && em <= 1),
      (thermal >= 0 && thermal <= 1),
      (kinetic >= 0 && kinetic <= 1),
      (explosive >= 0 && explosive <= 1)
    else {
      return nil
    }
    
    super.init(em: em, thermal: thermal, kinetic: kinetic, explosive: explosive)
  }
  
  static var emptyValue: ResistProfile {
    ResistProfile(0, thermal: 0, kinetic: 0, explosive: 0)!
  }
}
