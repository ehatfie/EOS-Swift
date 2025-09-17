//
//  Broker.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//
// https://github.com/pyfa-org/eos/blob/master/eos/pubsub/broker.py

// I think this `Message` could be a FitMessage
protocol MockSubscriberProtocol: Hashable {
  func notify(message: any Message)
}

class MockSubscriber: MockSubscriberProtocol, Equatable {
  let thing: Int

  init(thing: Int) {
    self.thing = thing
  }
  
  func notify(message: any Message) { }

}

enum MessageTypeEnum {
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
class FitMessageBroker<SubscriberType: MockSubscriberProtocol>: FitHaving {
  var fit: Fit {
    self as! Fit
  }
  
  var subscribers: [MessageTypeEnum: Set<SubscriberType>] = [:]

  init() {
    self.subscribers = [:]
  }

  /// Register subscriber for passed message types.
  func subscribe(subscriber: SubscriberType, for messageTypes: [MessageTypeEnum]) {
    for messageType in messageTypes {
      var set = subscribers[messageType, default: Set<SubscriberType>()]
      set.insert(subscriber)
      subscribers[messageType] = set
    }
  }

  /// Unregister subscriber from passed message types
  func unsubscribe(subscriber: SubscriberType, from messageTypes: [MessageTypeEnum])
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

  func publish<MessageType: Message>(_ message: MessageType) {
    var set: Set<SubscriberType> = []

    if let subscribersForType = subscribers[message.messageType] {
      for subscriber in subscribersForType {
        subscriber.notify(message: message)
      }
    }

    //return !set.isEmpty
  }
  
  func publish(messages: [any Message]) {
    for message in messages {
      var m = message
      for subscriber in self.subscribers[message.messageType] ?? [] {
        subscriber.notify(message: message)
      }
      //m.fit = self
      
    }
  }

}

/*
 class FitMsgBroker:
     """"""

     def __init__(self):
         # Format: {event class: {subscribers}}
         self.__subscribers = {}

     def _subscribe(self, subscriber, msg_types):
         """Register subscriber for passed message types."""
         for msg_type in msg_types:
             self.__subscribers.setdefault(msg_type, set()).add(subscriber)

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
