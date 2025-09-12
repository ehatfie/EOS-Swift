//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

protocol Message {
  var fit: Fit? { get set }
  var messageType: MessageTypeEnum { get }
}

struct ItemLoaded: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemLoaded
  let item: any BaseItemMixinProtocol
}

struct ItemUnloaded: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemUnloaded
  let item: any BaseItemMixinProtocol
}

struct StatesActivatedLoaded: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .StatesActivatedLoaded
  let item: any BaseItemMixinProtocol
  
  let states: Set<State>
}

struct StatesDeactivatedLoaded: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .StatesDeactivatedLoaded
  let item: any BaseItemMixinProtocol
  
  let states: Set<State>
}

struct EffectsStarted: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsStarted
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId> // [EffectId]
}

struct EffectsStopped: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsStopped
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId>
}

struct EffectsApplied: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsApplied
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId> // [EffectId]
  let targetItems: [any BaseItemMixinProtocol]
}

struct EffectsUnapplied: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsUnapplied
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId>
  let targetItems: [any BaseItemMixinProtocol]
}
