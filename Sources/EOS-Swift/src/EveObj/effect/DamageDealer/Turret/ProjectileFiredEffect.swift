//
//  ProjectileFiredEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 10/4/25.
//

/*
 class ProjectileFired(TurretDmgEffect):

     def _get_base_dmg_item(self, item):
         return self.get_charge(item)

     def get_cycles_until_reload(self, item):
         return get_cycles_until_reload_generic(item)
 */

class ProjectileFiredEffect: DamageDealerEffect, TurretDamageDealerEffectProtocol {
  func getBaseDamageItem(item: any BaseItemMixinProtocol) -> (any BaseItemMixinProtocol)? {
    return self.getCharge(item: item as! BaseItemMixin)
  }
  
  override func getCyclesUntilReload(item: any BaseItemMixinProtocol) -> Double {
    return getCyclesUntilReloadGeneric(item: item as! BaseItemMixin)
  }
}
