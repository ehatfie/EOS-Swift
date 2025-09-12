//
//  Subsystem.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

class Subsystem: ImmutableStateMixin {

  init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    
    modifierDomain = .ship
    ownerModifiable = false
    solsysCarrier = self.fit?.ship
  }
}
