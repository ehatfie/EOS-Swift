//
//  TurretDamageEffet.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 10/4/25.
//
protocol TurretDamageDealerEffectProtocol: DamageDealerEffect {
  /*
   @abstractmethod
   def _get_base_dmg_item(self, item):
       """Get item which carries base damage attributes."""
       ...

   def get_volley(self, item):
       if not self.get_cycles_until_reload(item):
           return DmgStats(0, 0, 0, 0)
       base_dmg_item = self._get_base_dmg_item(item)
       if base_dmg_item is None:
           return DmgStats(0, 0, 0, 0)
       em = base_dmg_item.attrs.get(AttrId.em_dmg, 0)
       therm = base_dmg_item.attrs.get(AttrId.therm_dmg, 0)
       kin = base_dmg_item.attrs.get(AttrId.kin_dmg, 0)
       expl = base_dmg_item.attrs.get(AttrId.expl_dmg, 0)
       mult = item.attrs.get(AttrId.dmg_mult)
       return DmgStats(em, therm, kin, expl, mult)

   def get_applied_volley(self, item, tgt_data):
       raise NotImplementedError
   */
  
  func getBaseDamageItem(item: any BaseItemMixinProtocol) -> (any BaseItemMixinProtocol)?
  func getVolley(item: any BaseItemMixinProtocol) -> DamageStats
  func getAppliedVolley(item: any BaseItemMixinProtocol, targetData: any BaseTargetableMixinProtocol) -> DamageStats
}

extension TurretDamageDealerEffectProtocol {
  func getVolley(item: any BaseItemMixinProtocol) -> DamageStats {
    guard let cyclesUntilReload = self.getCyclesUntilReload(item: item) else {
      return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0, mult: 1.0)!
    }
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
  
  func getAppliedVolley(item: any BaseItemMixinProtocol, targetData: any BaseTargetableMixinProtocol) -> DamageStats {
    return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0, mult: 1.0)!
  }
}
