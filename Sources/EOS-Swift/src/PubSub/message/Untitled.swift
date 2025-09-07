//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

protocol Message {
  var messageId: Int64 { get }
}


struct ItemAdded: Message {
  let messageId: Int64 = 0
  let fit: Fit?
}


struct itemRemoved: Message {
  let messageId: Int64 = 1
}

struct StatesActivated: Message {
  let messageId: Int64 = 2
}

struct StatesDeactivated: Message {
  let messageId: Int64 = 3
}
