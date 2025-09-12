//
//  Stance.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

class Stance: ImmutableStateMixin {
  init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    
    self.modifierDomain = .ship
    self.ownerModifiable = false
  }
}
