//
//  BaseStatsRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

public protocol BaseStatsRegisterProtocol: BaseSubscriberProtocol, EffectsSubscriberProtocol {
  var fit: Fit? { get set }
  
//  func handleEffectsStarted(message: EffectsStarted)
//  func handleEffectsStopped(message: EffectsStopped)
}



struct ItemEffectsMessage: Hashable {
  static func == (lhs: ItemEffectsMessage, rhs: ItemEffectsMessage) -> Bool {
    lhs.item.typeId == rhs.item.typeId
  }
  
  let item: any BaseItemMixinProtocol
  let effectIds: [Int64]
  let itemEffects: [Int64: Effect]
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
    hasher.combine(effectIds)
    hasher.combine(itemEffects)
  }
}
