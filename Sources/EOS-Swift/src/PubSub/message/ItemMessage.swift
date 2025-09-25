//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

struct ItemAdded: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemAdded
  let item: any BaseItemMixinProtocol
}

struct ItemRemoved: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .ItemRemoved
  let item: any BaseItemMixinProtocol
}

struct StatesActivated: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .StatesActivated
  let item: any BaseItemMixinProtocol
  
  let states: Set<StateI>
}

struct StatesDeactivated: ItemMessage {
  var fit: Fit?
  let messageType: MessageTypeEnum = .StatesDeactivated
  let item: any BaseItemMixinProtocol
  
  let states: Set<StateI>
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
