//
//  Character.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

/// Represents a character.
/// Character has to be represented as separate item, as eve tracks some attributes on it.
class Character: ImmutableStateMixin {
  var typeID: Int64
  
  init(typeID: Int64) {
    self.typeID = typeID
    super.init(typeId: typeID, state: .offline)
    modifierDomain = .character // nil
    ownerModifiable = false
    solsysCarrier = nil
  }
}

