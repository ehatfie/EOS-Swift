//
//  CapTransmit.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


/*
 class CapTransmitMixin(BaseItemMixin):

     def get_cap_transmit_per_second(self, reload=False):
         ctps = 0
         for effect in self._type_effects.values():
             if not isinstance(effect, BaseCapTransmitEffect):
                 continue
             if effect.id not in self._running_effect_ids:
                 continue
             ctps += effect.get_cap_transmit_per_second(self, reload=reload)
         return ctps

 */
protocol CapTransmitMixinProtocol: BaseItemMixinProtocol {
  func getCapTransmitPerSecond(reload: Bool) -> Double
}

extension CapTransmitMixinProtocol {
  func getCapTransmitPerSecond(reload: Bool = false) -> Double {
    var ctps: Double = 0
    let foo = self.typeEffects.values
    for effect in foo {
      if let foo = effect as? BaseCapTransmitEffect, self.runningEffectIds.contains(EffectId(rawValue: Int(foo.effectId))!) {
        ctps += foo.getCapTransmitPerSecond(item: self, reload: reload)
      }
    }
    return ctps
  }
}

class CapTransmitMixin: BaseItemMixin {
  
  func getCapTransmitPerSecond(reload: Bool = false) -> Double {
    var ctps: Double = 0
    let foo = self.typeEffects.values
    for effect in foo {
      if let foo = effect as? BaseCapTransmitEffect, self.runningEffectIds.contains(EffectId(rawValue: Int(foo.effectId))!) {
        ctps += foo.getCapTransmitPerSecond(item: self, reload: reload)
      }
    }
    return ctps
  }
}
