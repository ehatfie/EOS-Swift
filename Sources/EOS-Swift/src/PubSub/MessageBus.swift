//
//  MessageBus.swift
//  EOS-Swift
//
//  Centralized message bus for pub/sub messaging
//

import Foundation

/// Thread-safe message bus for publish-subscribe pattern
@MainActor
public final class MessageBus {
    
    /// Subscription storage
    private struct Subscription {
        weak var subscriber: (any BaseSubscriber)?
        var messageTypes: Set<MessageTypeEnum>
    }
    
    /// Active subscriptions indexed by subscriber ID
    private var subscriptions: [ObjectIdentifier: Subscription] = [:]
    
    /// Reverse index: message type -> subscriber IDs for fast lookup
    private var messageTypeIndex: [MessageTypeEnum: Set<ObjectIdentifier>] = [:]
    
    /// Queue for batched message processing
    private var messageQueue: [any Message] = []
    private var isProcessing = false
    
    public init() {}
    
    // MARK: - Subscription Management
    
    /// Subscribe to specific message types
    public func subscribe(
        subscriber: any BaseSubscriber,
        to messageTypes: Set<MessageTypeEnum>
    ) {
        let id = ObjectIdentifier(subscriber)
        
        // Update or create subscription
        if var existing = subscriptions[id] {
            let combined = existing.messageTypes.union(messageTypes)
            existing.messageTypes = combined
            subscriptions[id] = existing
        } else {
            subscriptions[id] = Subscription(
                subscriber: subscriber,
                messageTypes: messageTypes
            )
        }
        
        // Update reverse index
        for messageType in messageTypes {
            messageTypeIndex[messageType, default: []].insert(id)
        }
    }
    
    /// Unsubscribe from specific message types
    public func unsubscribe(
        subscriber: any BaseSubscriber,
        from messageTypes: Set<MessageTypeEnum>
    ) {
        let id = ObjectIdentifier(subscriber)
        
        guard var subscription = subscriptions[id] else { return }
        
        // Remove from reverse index
        for messageType in messageTypes {
            messageTypeIndex[messageType]?.remove(id)
            if messageTypeIndex[messageType]?.isEmpty == true {
                messageTypeIndex.removeValue(forKey: messageType)
            }
        }
        
        // Update subscription
        subscription.messageTypes.subtract(messageTypes)
        if subscription.messageTypes.isEmpty {
            subscriptions.removeValue(forKey: id)
        } else {
            subscriptions[id] = subscription
        }
    }
    
    /// Unsubscribe from all message types
    public func unsubscribeAll(subscriber: any BaseSubscriber) {
        let id = ObjectIdentifier(subscriber)
        guard let subscription = subscriptions[id] else { return }
        
        unsubscribe(subscriber: subscriber, from: subscription.messageTypes)
    }
    
    // MARK: - Publishing
    
    /// Publish a single message immediately
    public func publish(_ message: any Message) {
        let messageType = type(of: message).messageType
        
        guard let subscriberIds = messageTypeIndex[messageType] else {
            return
        }
        
        for id in subscriberIds {
            guard let subscription = subscriptions[id],
                  let subscriber = subscription.subscriber else {
                // Clean up dead subscribers
                cleanupDeadSubscriber(id: id)
                continue
            }
            
            subscriber.notify(message)
        }
    }
    
    /// Publish multiple messages in batch
    public func publishBatch(_ messages: [any Message]) {
        for message in messages {
            publish(message)
        }
    }
    
    /// Queue messages for deferred batch processing
    public func queueMessage(_ message: any Message) {
        messageQueue.append(message)
    }
    
    /// Process all queued messages
    public func processQueue() {
        guard !isProcessing else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let messages = messageQueue
        messageQueue.removeAll(keepingCapacity: true)
        
        publishBatch(messages)
    }
    
    // MARK: - Cleanup
    
    private func cleanupDeadSubscriber(id: ObjectIdentifier) {
        guard let subscription = subscriptions[id] else { return }
        
        // Remove from reverse index
        for messageType in subscription.messageTypes {
            messageTypeIndex[messageType]?.remove(id)
            if messageTypeIndex[messageType]?.isEmpty == true {
                messageTypeIndex.removeValue(forKey: messageType)
            }
        }
        
        // Remove subscription
        subscriptions.removeValue(forKey: id)
    }
    
    /// Clean up all dead subscribers
    public func cleanupDeadSubscribers() {
        let deadIds = subscriptions.compactMap { id, subscription in
            subscription.subscriber == nil ? id : nil
        }
        
        for id in deadIds {
            cleanupDeadSubscriber(id: id)
        }
    }
    
    // MARK: - Debugging
    
    public var activeSubscriberCount: Int {
        subscriptions.count
    }
    
    public var queuedMessageCount: Int {
        messageQueue.count
    }
}

// MARK: - Message Protocol Extension

extension Message {
    /// Default message type mapping - override in concrete types
    static var messageType: MessageTypeEnum {
        fatalError("Message types must define their messageType")
    }
}
