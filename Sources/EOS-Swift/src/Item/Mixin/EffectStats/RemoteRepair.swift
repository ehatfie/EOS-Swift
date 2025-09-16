//
//  RemoteRepair.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol RemoteRepairMixinProtocol: BaseItemMixinProtocol {
  func repairEffectIterator(effectClass: Effect.Type) -> AnyIterator<Effect>
  func getArmorRPS(reload: Bool) -> Double
  func getShieldRPS(reload: Bool) -> Double
}

extension RemoteRepairMixinProtocol {
  
  func repairEffectIterator(effectClass: Effect.Type) -> AnyIterator<Effect> {
    // only return active effects
    var values: [Effect] = self.typeEffects.values.filter {
      self.runningEffectIds.contains(EffectId(rawValue: Int($0.effectId))!)
    }
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func getArmorRPS(reload: Bool) -> Double {
    var rps: Double = 0
    for effect in self.repairEffectIterator(effectClass: RemoteArmorRepairEffect.self) {
      if let effect = effect as? RemoteArmorRepairEffect {
        rps += effect.getRps(item: self, relad: reload)
      }
    }
    return rps
  }
  
  func getShieldRPS(reload: Bool) -> Double {
    var rps: Double = 0
    for effect in self.repairEffectIterator(effectClass: RemoteShieldRepairEffect.self) {
      if let effect = effect as? RemoteShieldRepairEffect {
        rps += effect.getRps(item: self, relad: reload)
      }
    }
    return rps
  }
}

/*
 def __repair_effect_iter(self, effect_class):
         for effect in self._type_effects.values():
             if not isinstance(effect, effect_class):
                 continue
             if effect.id not in self._running_effect_ids:
                 continue
             yield effect

     def get_armor_rps(self, reload=False):
         rps = 0
         for effect in self.__repair_effect_iter(RemoteArmorRepairEffect):
             rps += effect.get_rps(self, reload=reload)
         return rps

     def get_shield_rps(self, reload=False):
         rps = 0
         for effect in self.__repair_effect_iter(RemoteShieldRepairEffect):
             rps += effect.get_rps(self, reload=reload)
         return rps
 */
