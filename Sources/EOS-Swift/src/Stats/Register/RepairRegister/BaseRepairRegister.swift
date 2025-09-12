//
//  BaseRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/8/25.
//

protocol BaseRepairRegisterProtocol: BaseStatsRegisterProtocol {
  
}

struct RepairerData: Hashable {
  static func == (lhs: RepairerData, rhs: RepairerData) -> Bool {
    return lhs.effect == rhs.effect
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
  
//  static func == (lhs: RepairerData, rhs: RepairerData) -> Bool {
//    return lhs.item == rhs.item && lhs.effect == rhs.effect
//  }
  
  let item: any BaseItemMixinProtocol
  let effect: BaseRepairEffect
}

