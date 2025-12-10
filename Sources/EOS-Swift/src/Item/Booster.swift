//
//  Booster.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

import Foundation

struct SideEffectData {
  let chance: Double
  let status: Bool
}

class Booster: ImmutableStateMixinProtocol {
  func load(from source: any BaseCacheHandlerProtocol) {
    
  }
  
  public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol> {
    print("!! booster bad childItemIterator impl")
    var values: [(any BaseItemMixinProtocol)?] = []
    var index: Int = 0
    
    if !skipAutoItems {
//      if let autocharges = self.autocharges {
//        values.append(contentsOf: autocharges.values())
//      }
    }
    
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
//  }
  
  var id: UUID = UUID()
  
  let SIDE_EFFECT_STATE = StateI.offline

  var typeId: Int64
  var itemType: ItemType?

  var container: (any ItemContainerBaseProtocol)?

  var runningEffectIds: Set<Int64> = []

  var effectModeOverrides: [Int64: EffectMode]?

  var effectTargets: String?

  var attributes: MutableAttributeMap?

  var _state: StateI
  var ownerModifiable: Bool
  var modifierDomain: ModDomain? = .character
  var solsysCarrier: Ship?

  var fit: Fit?

  init(typeId: Int64) {
    self.typeId = typeId
    _state = .offline
    modifierDomain = .character
    ownerModifiable = false
    solsysCarrier = nil
    attributes = MutableAttributeMap(item: self)
  }
  
  var autocharges: ItemDict<AutoCharge>?
  
  func clearAutocharges() { }
  

  var sideEffectChances: [Int64: Double] {
    var sideEffectChances: [Int64: Double] = [:]
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

  var sideEffects: [Int64: SideEffectData] {
    var chances = self.sideEffectChances
    let effectIds = Array(chances.keys)
    let statuses = EffectStatusResolver.resolveEffectsStatus(
      item: self,
      effectIds: effectIds,
      stateOverride: SIDE_EFFECT_STATE
    )
    var sideEffects: [Int64: SideEffectData] = [:]
    for (effectId, chance) in chances {
      guard let status = statuses[effectId] else {
        continue
      }
      sideEffects[effectId] = SideEffectData(chance: chance, status: status)
    }

    return sideEffects
  }

  func setSideEffectStatus(effectId: Int64, status: Bool) {
    print("++ setSideEffectStatus effectId: \(effectId) status: \(status)")
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
    return self.typeAttributes[AttrId.boosterness.rawValue]
  }
}
