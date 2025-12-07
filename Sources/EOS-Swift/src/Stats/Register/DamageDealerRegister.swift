public class DamageDealerRegister: BaseStatsRegisterProtocol {
  public static func == (lhs: DamageDealerRegister, rhs: DamageDealerRegister) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  typealias MessageType = ItemEffectsMessage

  public var handlerMap: [Int64 : CallbackHandler] = [:]
  
  weak public var fit: Fit?
  public var damageDealers: KeyedStorage<BaseItemMixin> = KeyedStorage()//[Int64: any DamageDealerMixinProtocol] = [:]
  public var test: KeyedStorage<DamageDealerMixin> = KeyedStorage()
  public init(fit: Fit) {
    self.fit = fit
    fit.subscribe(subscriber: self, for: [MessageTypeEnum.EffectsStarted, .EffectsStopped])
  }
  
  public func getVolley(itemFilter: Any?, targetResists: ResistProfile?) -> DamageStats {
    print("** getVolley")
    var damageStats: [DamageStats?] = []
    for item in ddIterator(itemFilter: nil) {
      damageStats.append(item.getVolley(targetResists: targetResists))
    }
    
    let result = DamageStats.combined(damageStats.compactMap { $0 })
    return result ?? DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
    
  }
  
  public func ddIterator(itemFilter: Any?) -> AnyIterator<any DamageDealerMixinProtocol> {
    let foo = Array(self.damageDealers.dictionary.values)
    let castFoo = foo as! [Set<BaseItemMixin>]
    let bar = castFoo.flatMap { $0 }
    
    let values = bar.map { value in
      value as! any DamageDealerMixinProtocol //as any DamageDealerMixinProtocol
    }
    print("++- ddIterator has \(values.count) items")
    var index = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }

  public func notify(message: any Message) {
    switch message {
      case let message as EffectsStarted:
      self.handleEffectsStarted(message: message)
    case let message as EffectsStopped:
      self.handleEffectsStopped(message: message)
    default:
      break
    }
  }
  
  public func getDps(
    itemFilter: Any?,
    reload: Bool,
    targetResists: ResistProfile?
  ) -> DamageStats {
    var dpsValues: [DamageStats] = []
    for item in self.ddIterator(itemFilter: itemFilter) {
      print("++ dd item \(item.itemType!.name)")
      
      if let dps = item.getDps(reload: reload, targetResists: targetResists) {
        dpsValues.append(dps)
      }
    }
    let combined = DamageStats.combined(dpsValues)
    print("++ getDPS \(dpsValues.count) values combined to \(combined?.em) \(combined?.kinetic ?? -1) \(combined?.thermal ?? -1) \(combined?.explosive ?? -1)")
    return combined ?? DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
  }
  
  public func handleEffectsStarted(message: EffectsStarted) {
    let itemEffects = message.item.typeEffects
    print("&& DDR handleEffectsStarted \(message.item.itemType?.name) \(message.effectIds) itemEffects \(itemEffects)")
    
    /*
     item_effects = msg.item._type_effects
     for effect_id in msg.effect_ids:
         effect = item_effects[effect_id]
         if isinstance(effect, DmgDealerEffect):
             self.__dmg_dealers.add_data_entry(msg.item, effect)
     */
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? DamageDealerEffect {
        if let foo = message.item as? (any DamageDealerMixinProtocol) {
          print("&& got damage dealer effect \(effect)")
          self.damageDealers.addDataEntry(key: effectId, data: message.item as! BaseItemMixin)
        } else {
          print("&& not DamageDealerMixinProtocol")
        }
      } else {
        print("&& not right effect is \(effectId)")
      }
    }
  }
  
  public func handleEffectsStopped(message: EffectsStopped) {
    let itemEffects = message.item.typeEffects
    for effectId in message.effectIds {
      if let effect = itemEffects[effectId] as? DamageDealerEffect {
        self.damageDealers.removeDataEntry(key: effect, data: message.item as! BaseItemMixin)
      }
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
