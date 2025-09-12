//
//  ShieldRepairerRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

class ShieldRepairerRegister: BaseRepairRegisterProtocol {
  typealias MessageType = ItemEffectsMessage
  
  var fit: Fit?
  
  var handlerMap: [Int64 : CallbackHandler]
  
  var localRepairers: [Int64 : RepairerData] = [:]
  var localRep: Set<RepairerData> = []
  
  init(fit: Fit? = nil) {
    self.fit = fit
    self.handlerMap = [:]
    
    // self.fit?.subscribe(subscriber: <#T##MockSubscriber#>, for: <#T##[MessageTypeEnum]#>)
  }
  
  func notify(_ message: Any) {
    
  }
  
  func getRps(
    item: any BufferTankingMixinProtocol,
    damageProfile: DamageProfile?,
    reload: Bool
  ) {
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
  }
  
  func handleEffectsStarted(message: ItemEffectsMessage) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? LocalShieldRepairEffect {
        let repairerData = RepairerData(item: message.item, effect: effect)
        self.localRep.insert(repairerData)
      }
    }
    /*
     item_effects = msg.item._type_effects
     for effect_id in msg.effect_ids:
         effect = item_effects[effect_id]
         if isinstance(effect, LocalShieldRepairEffect):
             self.__local_repairers.add((msg.item, effect))
     */
  }
  
  func handleEffectsEnded(message: ItemEffectsMessage) {
    /*
     item_effects = msg.item._type_effects
     for effect_id in msg.effect_ids:
         effect = item_effects[effect_id]
         if isinstance(effect, LocalShieldRepairEffect):
             self.__local_repairers.remove((msg.item, effect))
     */
    
    let itemEffects = message.itemEffects
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
