//
//  SolarSystem.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

protocol SolarSystemProtocol {
  
}

class MockSolarSystem: SolarSystemProtocol {
  
}

class SolarSystem: MaybeFitHaving {
  var source: Source?
  weak var fit: Fit?
  var calculator: CalculationService!
  
  var fits: [Fit] {
    return []
  }
  
  init(source: SourceManager?) {
    self.source = nil
    self.calculator = CalculationService(solarSystem: self)
    
    self.source = SourceManager.defaultValue
  }
}


class SourceManager {
  nonisolated(unsafe) static let defaultValue: SourceManager? = nil
  var sources: [String: Source] = [:]
}

struct Source {
  let alias: String
  let cacheHandler: () -> Void
}
