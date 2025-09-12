//
//  CalculationService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//


/*
 Service which supports attribute calculation.

 This class collects data about various items and relations between them, and
 via exposed methods which provice data about these connections helps
 attribute map to calculate modified attribute values.
 */

class CalculationService: BaseSubscriber {
  var handlerMap: [Int64 : CallbackHandler] = [:]
  
  weak var solarSystem: SolarSystem?
  var affections: Any? = nil // AffectionRegister
  var projections: Any? = nil // ProjectionRegister
  
  
  init(solarSystem: SolarSystem) {
    self.solarSystem = solarSystem
  }
  
  func notify(_ message: Any) {
    
  }
  
  
}
