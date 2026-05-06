//
//  Rig.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//

public class Rig: ImmutableStateMixin {

  public init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    modifierDomain = .ship
    ownerModifiable = false
  }
}
