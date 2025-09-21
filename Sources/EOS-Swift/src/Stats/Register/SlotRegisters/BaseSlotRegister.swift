//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

protocol BaseSlotRegisterProtocol: BaseStatsRegisterProtocol {
  var used: Int { get }
  var total: Int { get }
  var users: Set<AnyHashable> { get }
}



class BaseSlotRegister: BaseSlotRegisterProtocol {
  static func == (lhs: BaseSlotRegister, rhs: BaseSlotRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  var used: Int {
    0
  }
  
  var total: Int {
    0
  }
  
  var users: Set<AnyHashable> = []
  
  var fit: Fit?
  
  func handleEffectsStarted(message: EffectsStarted) { }
  
  func handleEffectsStopped(message: EffectsStopped) { }
  

  
  
}
