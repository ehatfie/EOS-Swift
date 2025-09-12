//
//  Implant.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//


class Implant: ImmutableStateMixin {
  init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    
    modifierDomain = .character
    ownerModifiable = false
    solsysCarrier = nil
  }
  
  var slot: Double? {
    return self.typeAttributes[AttrId.implantness]
  }
}
