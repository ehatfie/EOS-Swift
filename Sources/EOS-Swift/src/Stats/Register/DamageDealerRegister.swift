class DamageDealerRegister: BaseStatsRegisterProtocol {
  typealias MessageType = ItemEffectsMessage

  var handlerMap: [Int64 : CallbackHandler] = [:]
  
  var fit: Fit?
  var damageDealers: [Int64: any DamageDealerMixinProtocol] = [:]
  
  init(fit: Fit) {
    self.fit = fit
    // fit.subscribe(self.handlerMap.keys)
  }
  
  func getVolley(itemFilter: Any?, targetResists: ResistProfile) -> DamageStats {
    var damageStats: [DamageStats?] = []
    for item in ddIterator(itemFilter: nil) {
      damageStats.append(item.getVolley(targetResists: targetResists))
    }
    let result = DamageStats.combined(damageStats.compactMap { $0 })
    return result ?? DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
    
  }
  
  func ddIterator(itemFilter: Any?) -> AnyIterator<any DamageDealerMixinProtocol> {
    let values = Array(self.damageDealers.values).map { value in
      value as any DamageDealerMixinProtocol
    }
    
    var index = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
//    for (key, value) in self.damageDealers {
//      // check against itemFilter
//
//    }
  }
  
  /*
   def __dd_iter(self, item_filter):
       for item in self.__dmg_dealers:
           if item_filter is None or item_filter(item):
               yield item
   */
  
  
  func notify(_ message: Any) {
    
  }
  
  func getDps(
    itemFilter: Any?,
    reload: Bool,
    targetResists: ResistProfile
  ) -> DamageStats {
    var dpsValues: [DamageStats] = []
    for item in self.ddIterator(itemFilter: itemFilter) {
      if let dps = item.getDps(reload: reload, targetResists: targetResists) {
        dpsValues.append(dps)
      }
    }
    
    return DamageStats.combined(dpsValues) ?? DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
  }
  
  func handleEffectsStarted(message: MessageType) {
    let itemEffects = message.itemEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? DamageDealerEffect {
        if let foo = message.item as? (any DamageDealerMixinProtocol) {
          self.damageDealers[Int64(effectId.rawValue)] = foo
        }
      }
    }
  }
  
  func handleEffectsEnded(message: MessageType) {
    let itemEffects = message.itemEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? DamageDealerEffect {
        self.damageDealers[Int64(effectId.rawValue)] = nil
      }
    }
  }
}
