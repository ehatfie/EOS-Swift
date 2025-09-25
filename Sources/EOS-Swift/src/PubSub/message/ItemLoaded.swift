//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

public protocol Message {
  var fit: Fit? { get set }
  var messageType: MessageTypeEnum { get }
}

protocol ItemMessage: Message {
  var item: any BaseItemMixinProtocol { get }
}

protocol AttributeMessage: Message {
  var attributeChanges: [BaseItemMixin: [AttrId]] { get }
}

struct ItemLoaded: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemLoaded
  let item: any BaseItemMixinProtocol
}

struct ItemUnloaded: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemUnloaded
  let item: any BaseItemMixinProtocol
}

struct StatesActivatedLoaded: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .StatesActivatedLoaded
  let item: any BaseItemMixinProtocol
  
  let states: Set<StateI>
}

struct StatesDeactivatedLoaded: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .StatesDeactivatedLoaded
  let item: any BaseItemMixinProtocol
  
  let states: Set<StateI>
}

struct EffectsStarted: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsStarted
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId> // [EffectId]
}

struct EffectsStopped: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsStopped
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId>
}

struct EffectsApplied: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsApplied
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId> // [EffectId]
  let targetItems: [any BaseItemMixinProtocol]
}

struct EffectsUnapplied: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsUnapplied
  let item: any BaseItemMixinProtocol
  
  let effectIds: Set<EffectId>
  let targetItems: [any BaseItemMixinProtocol]
}

struct EffectApplied: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsUnapplied
  let item: any BaseItemMixinProtocol
  
  let effectId: EffectId
  let targetItems: [any BaseItemMixinProtocol]
}

struct EffectUnapplied: ItemMessage {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .EffectsUnapplied
  let item: any BaseItemMixinProtocol
  
  let effectId: EffectId
  let targetItems: [any BaseItemMixinProtocol]
}
