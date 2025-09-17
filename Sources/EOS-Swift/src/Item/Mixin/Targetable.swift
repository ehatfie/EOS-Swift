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
  var target: (any BaseItemMixinProtocol)? { get }
}

extension SingleTargetableMixinProtocol where Self: BaseItemMixinProtocol {
  
  func getEffectTargets(effectIds: [EffectId]) -> [(EffectId, [any BaseItemMixinProtocol])]? {
    var effectTargets: [EffectId: [any BaseItemMixinProtocol]] = [:]
    
    if let target {
      for effectId in effectIds {
        effectTargets[effectId] = [target]
      }
    }
    
    return effectTargets.map { ($0.key, $0.value)}
  }
  
}
//extension SingleTargetableMixinProtocol {
//  func getEffectTargets(effectIds: [EffectId]) -> [(EffectId, [any BaseItemMixinProtocol])]? {
//    var effectTargets: [EffectId: Any] = [:]
//    
//    if let target {
//      
//    }
//    
//    return nil
//  }
//}


