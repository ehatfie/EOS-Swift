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

public protocol ItemMessage: Message {
  var item: any BaseItemMixinProtocol { get }
}

public protocol AttributeMessage: Message {
  var attributeChanges: [BaseItemMixin: [Int64]] { get }
}

public struct ItemLoaded: ItemMessage {
  public var fit: Fit?
  public let messageType: MessageTypeEnum = .ItemLoaded
  public let item: any BaseItemMixinProtocol
}

public struct ItemUnloaded: ItemMessage {
  public var fit: Fit?
  public let messageType: MessageTypeEnum = .ItemUnloaded
  public let item: any BaseItemMixinProtocol
}

public struct StatesActivatedLoaded: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .StatesActivatedLoaded
  public let item: any BaseItemMixinProtocol
  
  public let states: Set<StateI>
}

public struct StatesDeactivatedLoaded: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .StatesDeactivatedLoaded
  public let item: any BaseItemMixinProtocol
  
  public let states: Set<StateI>
}

public struct EffectsStarted: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsStarted
  public let item: any BaseItemMixinProtocol
  public let effectIds: Set<Int64> // [EffectId]
}

public struct EffectsStopped: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsStopped
  public let item: any BaseItemMixinProtocol
  
  public let effectIds: Set<Int64>
}

public struct EffectsApplied: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsApplied
  public let item: any BaseItemMixinProtocol
  
  public let effectIds: Set<EffectId> // [EffectId]
  public let targetItems: [any BaseItemMixinProtocol]
}

public struct EffectsUnapplied: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsUnapplied
  public let item: any BaseItemMixinProtocol
  
  public  let effectIds: Set<Int64>
  public let targetItems: [any BaseItemMixinProtocol]
}

public struct EffectApplied: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsUnapplied
  public let item: any BaseItemMixinProtocol
  
  public let effectId: Int64
  public let targetItems: [any BaseItemMixinProtocol]
}

public struct EffectUnapplied: ItemMessage {
  public var fit: Fit? = nil
  public let messageType: MessageTypeEnum = .EffectsUnapplied
  public let item: any BaseItemMixinProtocol
  
  public let effectId: Int64
  public let targetItems: [any BaseItemMixinProtocol]
}
