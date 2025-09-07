//
//  BaseCapTransmitEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol BaseCapTransmitEffectProtocol: Effect {
  func getCapTransmitAmount(item: BaseItemMixin) -> Double
}

class BaseCapTransmitEffect: Effect, BaseCapTransmitEffectProtocol {
  func getCapTransmitAmount(item: BaseItemMixin) -> Double {
    
    return 0.0
  }
  
  func getCapTransmitPerSecond(item: BaseItemMixin, reload: Bool) -> Double {
    //let cycleParameters = self.getCycleParameters(item, reload: reload)
    return 0.0
  }
}
/*
 class BaseCapTransmitEffect(Effect, metaclass=ABCMeta):

     @abstractmethod
     def get_cap_transmit_amount(self, item):
         ...

     def get_cap_transmit_per_second(self, item, reload):
         cycle_parameters = self.get_cycle_parameters(item, reload)
         if cycle_parameters is None:
             return 0
         trans_amt = self.get_cap_transmit_amount(item)
         avg_cycle_time = cycle_parameters.average_time
         return trans_amt / avg_cycle_time
 */
