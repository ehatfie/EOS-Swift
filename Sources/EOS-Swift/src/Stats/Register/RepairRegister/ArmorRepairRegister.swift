//
//  ArmorRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

public class ArmorRepairerRegister: BaseRepairRegisterProtocol {
  typealias MessageType = ItemEffectsMessage
  
  public var localRepairers: [Int64 : RepairerData] = [:]
  
  public var fit: Fit?
  
  public var handlerMap: [Int64 : CallbackHandler] = [:]
  
  public init(fit: Fit) {
    self.fit = fit
    //let set = Set<(any BaseItemMixinProtocol, Effect)>()
    fit.subscribe(subscriber: self, for: [MessageTypeEnum.EffectsStarted, .EffectsStopped])
  }
  
  public func getRps(item: (any BaseItemMixinProtocol)?, damageProfile: DamageProfile?, reload: Bool) -> Double {
    var rps: Double = 0.0
    for (repItem, repEffect) in self.localRepairers {
      
    }
    return 0.0
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      guard let effect = itemEffects[effectId] else { continue }
      if effect is LocalArmorRepairEffect {
        //self.localRepairers[effectId] = RepairerData(item: message.item, effect: effect)
      }
    }
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    
  }
  
  public func notify(message: any Message) {
    switch message {
    case is EffectsStarted:
      handleEffectsStarted(message: message as! EffectsStarted)
    case is EffectsStopped:
      handleEffectsStopped(message: message as! EffectsStopped)
    default: break
    }
  }
}

extension ArmorRepairerRegister {

  public static func == (lhs: ArmorRepairerRegister, rhs: ArmorRepairerRegister) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
}
