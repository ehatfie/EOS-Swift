//
//  BaseRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/8/25.
//

protocol BaseRepairRegisterProtocol: BaseStatsRegisterProtocol {
  
}

public struct RepairerData<T: BaseRepairEffect>: Hashable {
  static public func == (lhs: RepairerData, rhs: RepairerData) -> Bool {
    return lhs.effect == rhs.effect //&& lhs.item.typeId == rhs.item.typeId
  }
  
  public func hash(into hasher: inout Hasher) {
    //hasher.combine(self)
    hasher.combine(item)
    hasher.combine(effect)
  }
  
  public let item: any BaseItemMixinProtocol
  public let effect: T
}

