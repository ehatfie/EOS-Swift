//
//  ArmorRepairRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//



public class ArmorRepairerRegister: BaseRepairRegisterProtocol {
  typealias MessageType = ItemEffectsMessage
  
  public var localRepairers: Set<RepairerData> = []
  
  public var fit: Fit?
  
  public var handlerMap: [Int64 : CallbackHandler] = [:]
  
  public init(fit: Fit) {
    self.fit = fit
    //let set = Set<(any BaseItemMixinProtocol, Effect)>()
    fit.subscribe(
      subscriber: self,
      for: [MessageTypeEnum.EffectsStarted, .EffectsStopped]
    )
  }
  /*
   def get_rps(self, item, dmg_profile, reload):
       rps = 0
       for rep_item, rep_effect in self.__local_repairers:
           if item is not rep_item._solsys_carrier:
               continue
           rps += rep_effect.get_rps(rep_item, reload)
       proj_reg = (
           self.__fit.solar_system._calculator.
           _CalculationService__projections)
       for rep_item, rep_effect in proj_reg.get_tgt_projectors(item):
           if not isinstance(rep_effect, RemoteArmorRepairEffect):
               continue
           rps += rep_effect.get_rps(rep_item, reload)
       if dmg_profile is not None:
           rps *= item._get_tanking_efficiency(
               dmg_profile, item.resists.armor)
       return rps
   */
  public func getRps(item: (any BaseItemMixinProtocol)?, damageProfile: DamageProfile?, reload: Bool) -> Double {
    var rps: Double = 0.0
    for value in self.localRepairers {
      let repItem = value.item
      let repEffect = value.effect
      
      rps += repEffect.getRps(item: repItem, relad: reload)
    }
    
    if let projectionRegister = self.fit?.solarSystem?.calculator.projections {
      for foo in projectionRegister.getTargetProjectors(targetItem: item!) {
        guard let item = foo as? BaseItemMixin else {
          print("++ projection item not BaseItemMixin")
          continue
        }
      }
    }
    
    return rps
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      guard let effect = itemEffects[effectId] else { continue }
      
      if let effect = effect as? LocalArmorRepairEffect {
        self.localRepairers.insert(
          RepairerData(item: message.item, effect: effect)
        )
      } else {
        print("++ HandleEffectsStarted not LocalArmorRepairEffect")
      }
    }
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      guard let effect = itemEffects[effectId] as? LocalArmorRepairEffect else {
        continue
      }
      self.localRepairers.remove(RepairerData(item: message.item, effect: effect))
    }
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
