//
//  Subscriber.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//
// https://github.com/pyfa-org/eos/blob/master/eos/pubsub/subscriber.py

/*
 class BaseSubscriber(metaclass=ABCMeta):
     """Base class for subscribers."""

     @property
     @abstractmethod
     def _handler_map(self):
         ...

     def _notify(self, msg):
         try:
             handler = self._handler_map[type(msg)]
         except KeyError:
             return
         handler(self, msg)
 */
/// Handler that receives a message and processes it
public typealias MessageHandler = (any Message) -> Void
public typealias CallbackHandler = () -> Void
/// Base protocol for subscribers in the PubSub system.
public protocol BaseSubscriber: AnyObject {
    /// Dictionary mapping message types to their handlers.
    var handlerMap: [MessageTypeEnum: CallbackHandler] { get }

    /// Notifies the subscriber about a message using its handler map.
    func notify(_ message: any Message)
}
