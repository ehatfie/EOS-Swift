//
//  Booster.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

struct SideEffectData {
  let chance: Double
  let status: Bool
}

class Booster: ImmutableStateMixinProtocol {
  let SIDE_EFFECT_STATE = State.offline

  var typeId: Int64
  var itemType: ItemType?

  var container: (any ItemContainerBaseProtocol)?

  var runningEffectIds: Set<EffectId> = []

  var effectModeOverrides: [EffectId: EffectMode]?

  var effectTargets: String?

  var attributes: [Int64: Double] = [:]

  var _state: State
  var ownerModifiable: Bool
  var modifierDomain: ModDomain = .character
  var solsysCarrier: Any?

  var fit: Fit?

  init(typeId: Int64) {
    self.typeId = typeId
    _state = .offline
    modifierDomain = .character
    ownerModifiable = false
    solsysCarrier = nil
  }

  var sideEffectChances: [EffectId: Double] {
    var sideEffectChances: [EffectId: Double] = [:]
    for (effectId, effect) in self.typeEffects {
      if effect.state != SIDE_EFFECT_STATE {
        continue
      }
      guard let chance = effect.getFittingUsageChance(item: self) else {
        continue
      }
      sideEffectChances[effectId] = chance
    }
    return sideEffectChances
  }

  var sideEffects: [EffectId: SideEffectData] {
    var chances = self.sideEffectChances
    let effectIds = Array(chances.keys)
    let statuses = EffectStatusResolver.resolveEffectsStatus(
      item: self,
      effectIds: effectIds,
      stateOverride: SIDE_EFFECT_STATE
    )
    var sideEffects: [EffectId: SideEffectData] = [:]
    for (effectId, chance) in chances {
      guard let status = statuses[effectId] else {
        continue
      }
      sideEffects[effectId] = SideEffectData(chance: chance, status: status)
    }

    return sideEffects
  }

  func setSideEffectStatus(effectId: EffectId, status: Bool) {
    guard self.sideEffectChances.keys.contains(effectId) else {
      return
    }
    let effectMode: EffectMode
    if status {
      effectMode = .state_compliance
    } else {
      effectMode = .full_compliance
    }
    self.setEffectMode(effectId: effectId, effectMode: effectMode)
  }

  func randomizeSideEffects() {
    print("++ randomizeSideEffects - TODO")
  }

  var slot: Double? {
    // return self._type_attrs.get(AttrId.boosterness)
    return self.typeAttributes[AttrId.boosterness]
  }
}
