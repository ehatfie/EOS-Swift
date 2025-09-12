//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

struct ItemAdded: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemAdded
  let item: any BaseItemMixinProtocol
}

struct ItemRemoved: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemRemoved
  let item: any BaseItemMixinProtocol
}

struct StatesActivated: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .StatesActivated
  let item: any BaseItemMixinProtocol
  
  let states: Set<State>
}

struct StatesDeactivated: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .StatesDeactivated
  let item: any BaseItemMixinProtocol
  
  let states: Set<State>
}

/*


 class StatesActivated:

     def __init__(self, item, states):
         self.fit = None
         self.item = item
         # Format: {states}
         self.states = states

 class StatesDeactivated:

     def __init__(self, item, states):
         self.fit = None
         self.item = item
         # Format: {states}
         self.states = states
 */
