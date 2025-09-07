//
//  FueldShieldRepair.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class FueledShieldBoosting: LocalShieldRepairEffect {
  override func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    return getCyclesUntilReloadGeneric(item: item)
  }
  
  override func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes[AttrId.shield_bonus.rawValue, default: 0]
  }
}
