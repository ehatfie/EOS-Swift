//
//  BaseRepairEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class BaseRepairEffect: Effect {
  open func getRepAmount(item: BaseItemMixin) -> Double? {
    return nil
  }
  
  func getRps(item: BaseItemMixin, relad: Bool) -> Double {
    let averageCycleTime: Double = 1.0
    let repAmount = self.getRepAmount(item: item) ?? 0.0
    
    return repAmount / averageCycleTime
  }
}

class LocalArmorRepairEffect: BaseRepairEffect {
  
}

class RemoteArmorRepairEffect: BaseRepairEffect {
  
}

class LocalShieldRepairEffect: BaseRepairEffect {
  
}

class RemoteShieldRepairEffect: BaseRepairEffect {
  
}
