//
//  NpcEntityRemoteShieldRepairer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class NpcEntityRemoteShieldRepairer: RemoteShieldRepairEffect {
  func getRepAmount(item: BaseItemMixin) -> Double? {
    return item.attributes?.getValue(attributeId: .shield_bonus) ?? 0.0
  }
}
