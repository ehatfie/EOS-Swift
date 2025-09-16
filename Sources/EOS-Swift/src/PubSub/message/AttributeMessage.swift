//
//  Untitled.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

struct AttributesValueChanged: AttributeMessage {
  var item: any BaseItemMixinProtocol
  
  var fit: Fit?
  let messageType: MessageTypeEnum = .AttributeValueChanged
  let attributeChanges: [BaseItemMixin: [AttrId]] 
}

struct AttributesValueChangedMasked: AttributeMessage {
  var item: any BaseItemMixinProtocol
  
  var fit: Fit?
  let messageType: MessageTypeEnum = .AttributeValueChangedMasked
  let attributeChanges: [BaseItemMixin: [AttrId]]
}
