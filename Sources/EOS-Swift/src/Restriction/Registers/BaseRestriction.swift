//
//  BaseRestrictionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//

protocol BaseRestrictionProtocol {
  func validate() throws
  
  var restrictionType: Restriction { get set }
}

// Base protocol for all restrictions which store some data on themselves
protocol BaseRestrictionRegisterProtocol: BaseSubscriberProtocol, BaseRestrictionProtocol, FitHaving {
  
}
