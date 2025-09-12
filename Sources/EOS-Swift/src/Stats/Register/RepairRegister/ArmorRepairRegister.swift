//
//  ArmorRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

class ArmorRepairerRegister: BaseRepairRegisterProtocol {
  typealias MessageType = ItemEffectsMessage
  
  var localRepairers: [Int64 : RepairerData] = [:]
  
  var fit: Fit?
  
  var handlerMap: [Int64 : CallbackHandler] = [:]
  
  func notify(_ message: Any) {
    
  }
  
  init(fit: Fit) {
    self.fit = fit
    //let set = Set<(any BaseItemMixinProtocol, Effect)>()
  }
  
  func handleEffectsStarted(message: ItemEffectsMessage) {
    let itemEffects = message.itemEffects
    for effectId in message.effectIds {
      guard let effect = itemEffects[effectId] else { continue }
      if effect is LocalArmorRepairEffect {
        //self.localRepairers[effectId] = RepairerData(item: message.item, effect: effect)
      }
    }
  }
  
  func handleEffectsEnded(message: ItemEffectsMessage) {
    
  }
}
