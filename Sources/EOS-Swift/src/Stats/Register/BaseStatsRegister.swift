//
//  BaseStatsRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

protocol BaseStatsRegisterProtocol: BaseSubscriberProtocol {
  var fit: Fit? { get set }
  associatedtype MessageType: Hashable
  
  func handleEffectsStarted(message: EffectsStarted)
  func handleEffectsEnded(message: EffectsStopped)
}



struct ItemEffectsMessage: Hashable {
  static func == (lhs: ItemEffectsMessage, rhs: ItemEffectsMessage) -> Bool {
    lhs.item.typeId == rhs.item.typeId
  }
  
  let item: any BaseItemMixinProtocol
  let effectIds: [EffectId]
  let itemEffects: [EffectId: Effect]
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
    hasher.combine(effectIds)
    hasher.combine(itemEffects)
  }
}
