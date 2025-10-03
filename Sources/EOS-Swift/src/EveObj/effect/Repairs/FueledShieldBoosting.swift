//
//  FueldShieldRepair.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class FueledShieldBoosting: LocalShieldRepairEffect {
  func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    return getCyclesUntilReloadGeneric(item: item)
  }
  
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes?[AttrId.shield_bonus, default: 0]
  }
}
