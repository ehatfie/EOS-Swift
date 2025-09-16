//
//  Neut.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol NeutMixinProtocol: BaseItemMixinProtocol {
  func getNps(reload: Bool) -> Double
}

extension NeutMixinProtocol {
  func getNps(reload: Bool = false) -> Double {
    var nps = 0.0
    
    for effect in self.typeEffects.values {
      if let foo = effect as? BaseNeutEffect,
         !self.runningEffectIds.contains(EffectId(rawValue: Int(foo.effectId))!) {
        nps += foo.getNeutPerSecond(item: self, reload: reload)
      }
    }
    return nps
  }
}

class NeutMixin: BaseItemMixin {
  func getNps(reload: Bool = false) -> Double {
    var nps = 0.0
    
    for effect in self.typeEffects.values {
      if let foo = effect as? BaseNeutEffect,
         !self.runningEffectIds.contains(EffectId(rawValue: Int(foo.effectId))!) {
        nps += foo.getNeutPerSecond(item: self, reload: reload)
      }
    }
    return nps
  }
}
