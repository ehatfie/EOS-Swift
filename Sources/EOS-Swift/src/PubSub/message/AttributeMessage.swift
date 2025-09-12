//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

struct AttributesValueChanged: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .AttributeValueChanged
  let attributeChanges: [(BaseItemMixin, [AttrId])]
}


struct AttributesValueChangedMasked: Message {
  var fit: Fit?
  let messageType: MessageTypeEnum = .AttributeValueChangedMasked
  let attributeChanges: [(BaseItemMixin, [AttrId])]
}
