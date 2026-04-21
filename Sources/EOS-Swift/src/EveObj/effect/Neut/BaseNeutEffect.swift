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
    guard let cycleParameters = self.getCycleParameters(item: item, reload: reload) else {
      print("!! getNeutPerSEcond no cycle parameters")
      return 0
    }
    
    guard let cycleTime = cycleParameters.0?.getTime() ?? cycleParameters.1?.getTime() else {
      print("!! no cycle time")
      return 0
    }
    
    guard let neutAmount = self.getNeutAmount(item: item) else {
      return 0
    }
    return neutAmount / cycleTime
  }
}


class EnergyNeutralizerFalloff: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    return item.attributes?[AttrId.energy_neutralizer_amount.rawValue, default: 0]
  }
}

class EnergyNosferatuFalloff: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    if item.attributes?[AttrId.nos_override.rawValue] != nil {
      return item.attributes?[AttrId.power_transfer_amount.rawValue, default: 0]
    }
    print("!! EnergyNosferatu verify this")
    return 0
  }
}

class EntityEnergyNeutralizerFallof: BaseNeutEffect {
  override func getNeutAmount(item: any BaseItemMixinProtocol) -> Double? {
    return item.attributes?[AttrId.energy_neutralizer_amount.rawValue, default: 0]
  }
}
