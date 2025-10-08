//
//  BaseRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/8/25.
//

protocol BaseRepairRegisterProtocol: BaseStatsRegisterProtocol {
  
}

public struct RepairerData: Hashable {
  static public func == (lhs: RepairerData, rhs: RepairerData) -> Bool {
    return lhs.effect == rhs.effect
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
  
  public let item: any BaseItemMixinProtocol
  public let effect: BaseRepairEffect
}

