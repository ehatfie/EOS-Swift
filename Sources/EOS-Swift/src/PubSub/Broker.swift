//
//  Broker.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//
// https://github.com/pyfa-org/eos/blob/master/eos/pubsub/broker.py

import Foundation

// I think this `Message` could be a FitMessage
public protocol BaseSubscriberProtocol: Hashable {
  func notify(message: any Message)
}



public class MockSubscriber: BaseSubscriberProtocol, Equatable {
  let thing: Int

  init(thing: Int) {
    self.thing = thing
  }
  
  public func notify(message: any Message) { }

}

public enum MessageTypeEnum {
  case AttributeValueChanged
  case AttributeValueChangedMasked
  
  case DefaultIncomingDamageChanged
  case RAHIncomingDamageChanged
  
  case FleetFitAdded
  case FleetFitRemoved
  
  case ItemLoaded
  case ItemUnloaded
  case StatesActivatedLoaded
  case StatesDeactivatedLoaded
  case EffectsStarted
  case EffectsStopped
  case EffectsApplied
  case EffectsUnapplied
  
  case ItemAdded
  case ItemRemoved
  case StatesActivated
  case StatesDeactivated
}

extension MockSubscriber: Hashable {
  public static func == (lhs: MockSubscriber, rhs: MockSubscriber) -> Bool {
    return lhs.thing == rhs.thing
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
/// I think this needs to be a protocol and implementations in an extension
/// Manages message subscriptions and dispatch messages to recipients.
public class FitMessageBroker<SubscriberType: BaseSubscriberProtocol>: MaybeFitHaving {
  public var fit: Fit? {
    print("FitMessageBroker \(self as? Fit)")
    return self as? Fit
  }
  
  public var subscribers: [MessageTypeEnum: Set<AnyHashable>] = [:]

  init() {
    self.subscribers = [:]
  }
  
  /// Register subscriber for passed message types.
  func subscribe(subscriber: any BaseSubscriberProtocol, for messageTypes: [MessageTypeEnum]) {
    for messageType in messageTypes {
      var set = subscribers[messageType, default: Set<AnyHashable>()]
      _ = set.insert(subscriber)
      subscribers[messageType] = set
    }
  }

  /// Unregister subscriber from passed message types
  func unsubscribe(subscriber: any BaseSubscriberProtocol, from messageTypes: [MessageTypeEnum])
  {
    var messageTypesToRemove: Set<MessageTypeEnum> = []

    for messageType in messageTypes {
      var set = subscribers[messageType, default: Set<SubscriberType>()]

      set.remove(subscriber)

      guard !set.isEmpty else {
        messageTypesToRemove.insert(messageType)
        continue
      }
      subscribers[messageType] = set
    }

    for messageType in messageTypesToRemove {
      self.subscribers[messageType] = nil
    }
  }

  /// Publish single message.
  // inout?
  func publish(message: any Message) {
    var m = message
    m.fit = fit
    for subscriber in self.subscribers[message.messageType] ?? [] {
      if let foo = subscriber as? any BaseSubscriberProtocol {
        foo.notify(message: m)
      }
      
    }
  }

  /// Publish multiple messages.
  func publishBulk(messages: [any Message]) {
    for message in messages {
      var m = message
      m.fit = self.fit
      for subscriber in self.subscribers[message.messageType] ?? [] {
        if let foo = subscriber as? any BaseSubscriberProtocol {
          foo.notify(message: m)
        }
      }
    }
  }
  
}

/*
 class FitMsgBroker:
     """"""

     def __init__(self):
         # Format: {event class: {subscribers}}
         self.__subscribers = {}

     def _unsubscribe(self, subscriber, msg_types):
         """Unregister subscriber from passed message types."""
         msgtypes_to_remove = set()
         for msg_type in msg_types:
             try:
                 subscribers = self.__subscribers[msg_type]
             except KeyError:
                 continue
             subscribers.discard(subscriber)
             if not subscribers:
                 msgtypes_to_remove.add(msg_type)
         for msg_type in msgtypes_to_remove:
             del self.__subscribers[msg_type]

     def _publish(self, msg):
         """Publish single message."""
         msg.fit = self
         for subscriber in self.__subscribers.get(type(msg), ()):
             subscriber._notify(msg)

     def _publish_bulk(self, msgs):
         """Publish multiple messages."""
         for msg in msgs:
             msg.fit = self
             for subscriber in self.__subscribers.get(type(msg), ()):
                 subscriber._notify(msg)

 */
