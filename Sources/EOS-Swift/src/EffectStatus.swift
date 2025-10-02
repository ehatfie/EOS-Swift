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
    let effectId = EffectId(rawValue: Int(effectId))!
    let effectStatus = EffectStatusResolver.resolveEffectsStatus(item: item, effectIds: [effectId])
    return effectStatus[effectId, default: false]
  }

  static func resolveEffectsStatus(
    item: any BaseItemMixinProtocol,
    effectIds: [EffectId]? = nil,
    stateOverride: StateI? = nil
  ) -> [EffectId: Bool] {
    let itemEffects = item.typeEffects  //.filter(\.id.in(effectIds))
    var requiredEffectIds: Set<EffectId> = []
    

    if let effectIds {
      requiredEffectIds = Set(effectIds).intersection(itemEffects.keys)
    } else {
      requiredEffectIds = Set(itemEffects.keys)
    }
    
    var effectsStatus: [EffectId: Bool] = [:]
    let onlineRunning: Bool
    if item.effects.contains(where: { $0.key == .online }) {
      onlineRunning = EffectStatusResolver.resolveEffectStatus2(
        item: item,
        effect: itemEffects[.online]!,
        onlineOrRunning: false // maybe verify
      )
      if requiredEffectIds.contains(.online) {
        effectsStatus[.online] = onlineRunning
      }
    } else {
      onlineRunning = false
    }
    
    for effectId in requiredEffectIds {
      if effectId == .online {
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

  static func resolveEffectStatus2(
    item: any BaseItemMixinProtocol,
    effect: Effect,
    onlineOrRunning: Bool,
    stateOverride: StateI? = nil
  ) -> Bool {
    var resolverMap: [EffectMode: Any] = [
      EffectMode.full_compliance: EffectStatusResolver.resolveFullCompliance,
      EffectMode.state_compliance: EffectStatusResolver.resolveStateCompliance,
      EffectMode.force_run: EffectStatusResolver.resolveForceRun,
      EffectMode.force_stop: EffectStatusResolver.resolveForceStop,
    ]
    let effectMode = item.getEffectMode(effectId: EffectId(rawValue: Int(effect.effectId))!)
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
