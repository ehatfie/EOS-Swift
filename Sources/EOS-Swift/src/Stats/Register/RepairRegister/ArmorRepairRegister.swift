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
  
  init(fit: Fit) {
    self.fit = fit
    //let set = Set<(any BaseItemMixinProtocol, Effect)>()
    fit.subscribe(subscriber: self, for: [MessageTypeEnum.EffectsStarted, .EffectsStopped])
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      guard let effect = itemEffects[effectId] else { continue }
      if effect is LocalArmorRepairEffect {
        //self.localRepairers[effectId] = RepairerData(item: message.item, effect: effect)
      }
    }
  }
  
  func handleEffectsEnded(message: EffectsStopped) {
    
  }
  
  func notify(message: any Message) {
    switch message {
    case is EffectsStarted:
      handleEffectsStarted(message: message as! EffectsStarted)
    case is EffectsStopped:
      handleEffectsEnded(message: message as! EffectsStopped)
    default: break
    }
  }
}

extension ArmorRepairerRegister {

  

  
  static func == (lhs: ArmorRepairerRegister, rhs: ArmorRepairerRegister) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  
}
