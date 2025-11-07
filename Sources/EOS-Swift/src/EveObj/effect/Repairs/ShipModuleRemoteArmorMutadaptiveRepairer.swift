//
//  ShipModuleRemoteArmorMutadaptiveRepairer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


class ShipModuleRemoteArmorMutadaptiveRepairer: RemoteArmorRepairEffect {
  func getRepAmount(item: BaseItemMixin) -> Double? {
    let repAmmount = item.attributes![AttrId.armor_dmg_amount.rawValue, default: 0]
    let spoolMult: Double
    if let spoolBonus = item.attributes?[AttrId.repair_mult_bonus_max.rawValue] {
      spoolMult = 1 + spoolBonus
    } else {
      spoolMult = 1
    }
    return repAmmount * spoolMult
  }
}
