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
  var source: Any?
  weak var fit: Fit?
  // var calculator = CalculationService
}
