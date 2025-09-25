//
//  ShieldRepairerRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

class ShieldRepairerRegister: BaseRepairRegisterProtocol {
  static func == (lhs: ShieldRepairerRegister, rhs: ShieldRepairerRegister) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  typealias MessageType = ItemEffectsMessage
  
  var fit: Fit?
  
  var handlerMap: [Int64 : CallbackHandler]
  
  var localRepairers: [Int64 : RepairerData] = [:]
  var localRep: Set<RepairerData> = []
  
  init(fit: Fit? = nil) {
    self.fit = fit
    self.handlerMap = [:]
    fit?.subscribe(subscriber: self, for: [MessageTypeEnum.EffectsStarted, .EffectsStopped])
  }
  
  func notify(message: any Message) {
    switch message {
    case let message as EffectsStarted:
      self.handleEffectsStarted(message: message)
    case let message as EffectsStopped:
      self.handleEffectsStopped(message: message)
    default: break
    }
  }
  
  // TODO
  func getRps(
    item: (any BufferTankingMixinProtocol)?,
    damageProfile: DamageProfile?,
    reload: Bool
  ) -> Double {
    guard let item = item else { return 0.0 }
    var rps: Double = 0.0
    for (key, value) in self.localRepairers {
      let repItem = value.item
      let repEffect = value.effect
      //
      rps += repEffect.getRps(item: repItem, relad: reload)
      
      // if item is not rep_item._solsys_carrier:
      //rps += rep_effect.get_rps(rep_item, reload)
      //rps += repEffect.get
    }
    /*
     proj_reg = (
         self.__fit.solar_system._calculator.
         _CalculationService__projections)
     for rep_item, rep_effect in proj_reg.get_tgt_projectors(item):
         if not isinstance(rep_effect, RemoteShieldRepairEffect):
             continue
         rps += rep_effect.get_rps(rep_item, reload)
     if dmg_profile is not None:
         rps *= item._get_tanking_efficiency(
             dmg_profile, item.resists.shield)
     */
    
    //let projectionReg = self.fit?.pr
    
    if let damageProfile {
      rps *= item.getTankingEfficiency(damageProfile: damageProfile, resists: item.resists.shield)
    }
    
    return rps
  }
  
  func handleEffectsStarted(message: EffectsStarted) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? LocalShieldRepairEffect {
        let repairerData = RepairerData(item: message.item, effect: effect)
        self.localRep.insert(repairerData)
      }
    }
  }
  
  func handleEffectsStopped(message: EffectsStopped) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? LocalShieldRepairEffect {
        // This feels like it could be an issue
        self.localRep.remove(RepairerData(item: message.item, effect: effect))
      }
    }
  }
  
  /*
   _handler_map = {
       EffectsStarted: _handle_effects_started,
       EffectsStopped: _handle_effects_stopped}
   */
}
