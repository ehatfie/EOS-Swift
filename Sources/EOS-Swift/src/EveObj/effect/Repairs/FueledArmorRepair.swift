//
//  FueldArmorRepair.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class FueledArmorRepair: LocalArmorRepairEffect {
  func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    return getCyclesUntilReloadGeneric(item: item, default: .infinity)
  }
  
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes?[AttrId.armor_dmg_amount, default: 0]
  }
}
