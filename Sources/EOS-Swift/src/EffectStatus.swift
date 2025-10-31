//
//  EffectStatus.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

typealias Resolver = (any BaseItemMixinProtocol, Effect, Bool, StateI?) -> Bool

struct EffectStatus {
  
}

class EffectStatusResolver {
  static func resolveEffectStatus(
    item: any BaseItemMixinProtocol,
    effectId: Int64,
    stateOverride: StateI? = nil
  ) -> Bool {
    let effectStatus = EffectStatusResolver.resolveEffectsStatus(item: item, effectIds: [effectId])
    return effectStatus[effectId, default: false]
  }

  static func resolveEffectsStatus(
    item: any BaseItemMixinProtocol,
    effectIds: [Int64]? = nil,
    stateOverride: StateI? = nil
  ) -> [Int64: Bool] {
    print(":: ")
    print(":: resolveEffectStatus for \(item.typeId) \(item.itemType?.name)")
    let itemEffects = item.typeEffects  //.filter(\.id.in(effectIds))
    var requiredEffectIds: Set<Int64> = []

    if let effectIds {
      requiredEffectIds = Set(effectIds).intersection(itemEffects.keys)
    } else {
      requiredEffectIds = Set(itemEffects.keys)
    }
    print(":: required effectIds \(requiredEffectIds.count)")
    var effectsStatus: [Int64: Bool] = [:]
    let onlineRunning: Bool
    if item.effects.contains(where: { $0.key == EffectId.online.rawValue }) {
      onlineRunning = EffectStatusResolver.resolveEffectStatus2(
        item: item,
        effect: itemEffects[Int64(EffectId.online.rawValue)]!,
        onlineOrRunning: false // maybe verify
      )
      if requiredEffectIds.contains(Int64(EffectId.online.rawValue)) {
        print(":: adding online required effectIds \(onlineRunning)")
        effectsStatus[Int64(EffectId.online.rawValue)] = onlineRunning
      }
    } else {
      print(":: doesnt contain online in \(item.effects) \(item.effects[EffectId.online.rawValue])")
      onlineRunning = false
    }
    
    for effectId in requiredEffectIds {
      if effectId == Int64(EffectId.online.rawValue) {
        continue
      }
      let effect = itemEffects[effectId]!
      
      let status = EffectStatusResolver.resolveEffectStatus2(
        item: item,
        effect: effect,
        onlineOrRunning: onlineRunning,
        stateOverride: stateOverride
      )
      effectsStatus[effectId] = status
    }
    return effectsStatus
  }
  
  /*
   item_effects = item._type_effects
   if effect_ids is None:
       rq_effect_ids = set(item_effects)
   else:
       rq_effect_ids = set(effect_ids).intersection(item_effects)
   effects_status = {}
   # Process 'online' effect separately, as it's needed for all other
   # effects from online categories
   if EffectId.online in item_effects:
       online_running = EffectStatusResolver.__resolve_effect_status(
           item, item_effects[EffectId.online], None, state_override)
       if EffectId.online in rq_effect_ids:
           effects_status[EffectId.online] = online_running
   else:
       online_running = False
   # Process the rest of effects
   for effect_id in rq_effect_ids:
       if effect_id == EffectId.online:
           continue
       effect = item_effects[effect_id]
       effect_status = EffectStatusResolver.__resolve_effect_status(
           item, effect, online_running, state_override)
       effects_status[effect_id] = effect_status
   return effects_status
   */

  static func resolveEffectStatus2(
    item: any BaseItemMixinProtocol,
    effect: Effect,
    onlineOrRunning: Bool,
    stateOverride: StateI? = nil
  ) -> Bool {
    print(":: resolveEffectStatus2")

    var resolverMap: [EffectMode: Any] = [
      EffectMode.full_compliance: EffectStatusResolver.resolveFullCompliance,
      EffectMode.state_compliance: EffectStatusResolver.resolveStateCompliance,
      EffectMode.force_run: EffectStatusResolver.resolveForceRun,
      EffectMode.force_stop: EffectStatusResolver.resolveForceStop,
    ]
    let effectMode = item.getEffectMode(effectId: effect.effectId)
    print(":: itemEffectMode \(effectMode)")
    let resolver = resolverMap[effectMode]!
    if let resolver = resolver
      as? (any BaseItemMixinProtocol, Effect, Bool, StateI?) -> Bool
    {
      return resolver(item, effect, onlineOrRunning, stateOverride)
    }
    
    switch effectMode {
    case .full_compliance:
      return resolveFullCompliance(
        item: item,
        effect: effect,
        onlineOrRunning: onlineOrRunning
      )
    case .state_compliance:
      return resolveStateCompliance(
        item: item,
        effect: effect,
        onlineOrRunning: onlineOrRunning
      )
    case .force_run:
      return resolveForceRun()
    case .force_stop:
      return resolveForceStop()
    }
  }

  static func resolveFullCompliance(
    item: any BaseItemMixinProtocol,
    effect: Effect,
    onlineOrRunning: Bool,
    stateOverride: StateI? = nil
  ) -> Bool {
    
    let itemState: StateI = stateOverride ?? item._state
    let effectState: StateI = effect.state
    if itemState < effectState {
      return false
    }
    print(":: resolveFullCompliance for \(item.itemType?.name) itemState \(itemState) effectState \(effectState)")
    switch effectState {
    case .offline:
      return effect.fittingUseUsageChanceAttributeID == nil
    case .online:
      if effect.effectId == EffectId.online.rawValue {
        return true
      } else {
        return onlineOrRunning
      }
    case .active:
      //print("++ EffectState for \(effect.effectId) == active \(item.typeId)  !!!")
      print(":: item.typeDefaultEffect \(item.typeDefaultEffect)")
      return item.typeDefaultEffect is Effect
    case .overload:
      return true
    }

  }

  static func resolveStateCompliance(
    item: any BaseItemMixinProtocol,
    effect: Effect,
    onlineOrRunning: Bool,
    stateOverride: StateI? = nil
  ) -> Bool {
    let itemState: StateI = stateOverride ?? item._state
    return itemState >= effect.state
  }

  static func resolveForceRun() -> Bool {
    return true
  }
  static func resolveForceStop() -> Bool {
    return false
  }
}
