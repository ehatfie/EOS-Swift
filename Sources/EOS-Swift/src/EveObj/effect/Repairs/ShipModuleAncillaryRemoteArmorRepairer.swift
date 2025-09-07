//
//  ShipModuleAncillaryRemoteArmorRepairer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


class ShipModuleAncillaryRemoteArmorRepairer: RemoteArmorRepairEffect {
  override func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    getCyclesUntilReloadGeneric(item: item, default: .infinity)
  }
  
  override func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes[AttrId.armor_dmg_amount.rawValue, default: 0]
  }
}
