//
//  ShipModuleAncillaryRemoteShieldRepairer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


class ShipModuleAncillaryRemoteShieldRepairer: RemoteShieldRepairEffect {
  func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    getCyclesUntilReloadGeneric(item: item, default: .infinity)
  }
  
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes[AttrId.shield_bonus.rawValue, default: 0]
  }
}
