//
//  BaseRepairEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public class BaseRepairEffect: Effect {
  open func getRepAmount(item: any BaseItemMixinProtocol) -> Double? {
    return nil
  }
  
  public func getRps(item: any BaseItemMixinProtocol, relad: Bool) -> Double {
    print("&& BaseRepairEffect getRps")
    let averageCycleTime: Double = 1.0
    let repAmount = self.getRepAmount(item: item) ?? 0.0
    
    return repAmount / averageCycleTime
  }
}

class LocalArmorRepairEffect: BaseRepairEffect {
  
}

class RemoteArmorRepairEffect: BaseRepairEffect {
  
}

public class LocalShieldRepairEffect: BaseRepairEffect {
  override public func getRepAmount(item: any BaseItemMixinProtocol) -> Double? {
    return item.attributes?.getValue(attributeId: AttrId.shield_bonus) ?? 0
  }
}

class RemoteShieldRepairEffect: BaseRepairEffect {
  
}
