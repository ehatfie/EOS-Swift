//
//  FleetMessage.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

class FleetFitAdded: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .FleetFitAdded
}

class FleetFitRemoved: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .FleetFitRemoved
}
