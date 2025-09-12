//
//  BaseNeutEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class BaseNeutEffect: Effect {
  open func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    return nil
  }
  
  func getNeutPerSecond(item: any BaseItemMixinProtocol, reload: Bool) -> Double {
    let cycleParameters = 1.0
//    guard let cycleParameters = self.getCycleParameters(item: item, reload: reload) else {
//      return 0
    
//    }
    guard let neutAmount = self.getNeutAmount(item: item) else {
      return 0
    }
    return neutAmount / cycleParameters
  }
}


class EnergyNeutralizerFalloff: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    return item.attributes[AttrId.energy_neutralizer_amount.rawValue, default: 0]
  }
}

class EnergyNosferatuFalloff: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    if let nosOvveride = item.attributes[AttrId.nos_override.rawValue] {
      return item.attributes[AttrId.power_transfer_amount.rawValue, default: 0]
    }
                
    return 0
  }
}

class EntityEnergyNeutralizerFallof: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    return item.attributes[AttrId.energy_neutralizer_amount.rawValue, default: 0]
  }
}
