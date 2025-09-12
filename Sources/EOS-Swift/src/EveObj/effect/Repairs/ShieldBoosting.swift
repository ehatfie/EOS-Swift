//
//  ShieldBoosting.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class ShieldBoosting: LocalShieldRepairEffect {
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes[AttrId.shield_bonus.rawValue, default: 0]
  }
}
