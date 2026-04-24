////
////  Message.swift
////  EOS-Swift
////
////  Core message protocol and types for PubSub system
////
//
//import Foundation
//
///// Base protocol for all messages in the PubSub system
//public protocol Message: Sendable {
//    /// The type identifier for this message
//    static var messageType: MessageTypeEnum { get }
//}
//
///// Enumeration of all message types in the system
//public enum MessageTypeEnum: Hashable, CaseIterable, Sendable {
//    case FleetFitAdded
//    case FleetFitRemoved
//    case ItemLoaded
//    case ItemUnloaded
//    case EffectsStarted
//    case EffectsStopped
//    case EffectApplied
//    case EffectUnapplied
//    case AttrsValueChanged
//    case AttrsValueChangedMasked
//}
//
//// MARK: - Concrete Message Types
//
///// Message sent when a fit is added to a fleet
//public struct FleetFitAdded: Message {
//    public static let messageType: MessageTypeEnum = .FleetFitAdded
//    public let fit: Fit
//    
//    public init(fit: Fit) {
//        self.fit = fit
//    }
//}
//
///// Message sent when a fit is removed from a fleet
//public struct FleetFitRemoved: Message {
//    public static let messageType: MessageTypeEnum = .FleetFitRemoved
//    public let fit: Fit
//    
//    public init(fit: Fit) {
//        self.fit = fit
//    }
//}
//
///// Message sent when an item is loaded into the system
//public struct ItemLoaded: Message {
//    public static let messageType: MessageTypeEnum = .ItemLoaded
//    public let item: any BaseItemMixinProtocol
//    
//    public init(item: any BaseItemMixinProtocol) {
//        self.item = item
//    }
//}
//
///// Message sent when an item is unloaded from the system
//public struct ItemUnloaded: Message {
//    public static let messageType: MessageTypeEnum = .ItemUnloaded
//    public let item: any BaseItemMixinProtocol
//    
//    public init(item: any BaseItemMixinProtocol) {
//        self.item = item
//    }
//}
//
///// Message sent when effects are started on an item
//public struct EffectsStarted: Message {
//    public static let messageType: MessageTypeEnum = .EffectsStarted
//    public let item: any BaseItemMixinProtocol
//    public let effectIds: [Int64]
//    
//    public init(item: any BaseItemMixinProtocol, effectIds: [Int64]) {
//        self.item = item
//        self.effectIds = effectIds
//    }
//}
//
///// Message sent when effects are stopped on an item
//public struct EffectsStopped: Message {
//    public static let messageType: MessageTypeEnum = .EffectsStopped
//    public let item: any BaseItemMixinProtocol
//    public let effectIds: [Int64]
//    
//    public init(item: any BaseItemMixinProtocol, effectIds: [Int64]) {
//        self.item = item
//        self.effectIds = effectIds
//    }
//}
//
///// Message sent when an effect is applied
//public struct EffectApplied: Message {
//    public static let messageType: MessageTypeEnum = .EffectApplied
//    public let item: any BaseItemMixinProtocol
//    public let effectId: Int64
//    public let targetItems: [any BaseItemMixinProtocol]
//    
//    public init(
//        item: any BaseItemMixinProtocol,
//        effectId: Int64,
//        targetItems: [any BaseItemMixinProtocol]
//    ) {
//        self.item = item
//        self.effectId = effectId
//        self.targetItems = targetItems
//    }
//}
//
///// Message sent when an effect is unapplied
//public struct EffectUnapplied: Message {
//    public static let messageType: MessageTypeEnum = .EffectUnapplied
//    public let item: any BaseItemMixinProtocol
//    public let effectId: Int64
//    public let targetItems: [any BaseItemMixinProtocol]
//    
//    public init(
//        item: any BaseItemMixinProtocol,
//        effectId: Int64,
//        targetItems: [any BaseItemMixinProtocol]
//    ) {
//        self.item = item
//        self.effectId = effectId
//        self.targetItems = targetItems
//    }
//}
//
///// Message sent when attribute values change
//public struct AttrsValueChanged: Message {
//    public static let messageType: MessageTypeEnum = .AttrsValueChanged
//    public let changes: [any BaseItemMixinProtocol: Set<Int64>]
//    
//    public init(changes: [any BaseItemMixinProtocol: Set<Int64>]) {
//        self.changes = changes
//    }
//}
//
///// Message sent when masked attribute values change
//public struct AttrsValueChangedMasked: Message {
//    public static let messageType: MessageTypeEnum = .AttrsValueChangedMasked
//    public let changes: [any BaseItemMixinProtocol: Set<Int64>]
//    
//    public init(changes: [any BaseItemMixinProtocol: Set<Int64>]) {
//        self.changes = changes
//    }
//}
