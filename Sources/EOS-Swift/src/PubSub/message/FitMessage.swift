//
//  FitMessage.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

struct DefaultIncomingDamageChanged: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .DefaultIncomingDamageChanged
}

struct RAHIncomingDamageChanged: Message {
  var fit: Fit? = nil
  let messageType: MessageTypeEnum = .RAHIncomingDamageChanged
}
