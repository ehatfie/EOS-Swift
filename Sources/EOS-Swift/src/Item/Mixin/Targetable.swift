//
//  Targetable.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


protocol BaseTargetableMixinProtocol {
  func getEffectTargets(effectIds: [EffectId]) -> [(EffectId, [any BaseItemMixinProtocol])]?
}

class BaseTargetableMixin: BaseTargetableMixinProtocol {
  func getEffectTargets(effectIds: [EffectId]) -> [(EffectId, [any BaseItemMixinProtocol])]? {
    return nil
  }
}

protocol SingleTargetableMixinProtocol: BaseTargetableMixinProtocol {
  var target: Any? { get }
}
