//
//  ArmorRepair.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class ArmorRepair: LocalArmorRepairEffect {
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes[AttrId.armor_dmg_amount.rawValue, default: 0]
  }
}
