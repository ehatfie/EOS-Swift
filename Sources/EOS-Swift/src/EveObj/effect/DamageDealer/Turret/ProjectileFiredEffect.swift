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
  override func getVolley(for item: any BaseItemMixinProtocol) -> DamageStats {
    let cyclesUntilReload = self.getCyclesUntilReload(item: item)
//    guard let cyclesUntilReload = self.getCyclesUntilReload(item: item) else {
//      return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0, mult: 1.0)!
//    }
    guard let baseDamageItem = self.getBaseDamageItem(item: item) else {
      return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0, mult: 1.0)!
    }
    
    let em = baseDamageItem.attributes?.getValue(attributeId: .em_dmg) ?? 0.0
    let thermal = baseDamageItem.attributes?.getValue(attributeId: .therm_dmg) ?? 0.0
    let kin = baseDamageItem.attributes?.getValue(attributeId: .kin_dmg) ?? 0.0
    let expl = baseDamageItem.attributes?.getValue(attributeId: .expl_dmg) ?? 0.0
    let mult = item.attributes?.getValue(attributeId: .dmg_mult)
    
    return DamageStats(em: em, thermal: thermal, kinetic: kin, explosive: 0, mult: mult)!
  }
  
  func getBaseDamageItem(item: any BaseItemMixinProtocol) -> (any BaseItemMixinProtocol)? {
    return self.getCharge(item: item as! BaseItemMixin)
  }
  
  override func getCyclesUntilReload(item: any BaseItemMixinProtocol) -> Double {
    return getCyclesUntilReloadGeneric(item: item as! BaseItemMixin)
  }
}
