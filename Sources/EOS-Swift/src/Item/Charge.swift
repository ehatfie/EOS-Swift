//
//  Charge.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public class BaseCharge: ContainerStateMixin {
  public init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    modifierDomain = .ship
    ownerModifiable = true
  }
}


public class Charge: BaseCharge {
  /*
   """Represents a regular charge.

   Regular charges are manually loadable into various container items, e.g.
   various crystals, scanning probes and bombs loadable by eos user into
   modules.

   Args:
       type_id: Identifier of item type which should serve as base for this
           charge.
   """
   */
}

public class AutoCharge: BaseCharge {
  /*
   """Represents an autocharge.

   Autocharges are spawned automatically when item type specifies it via its
   effects, eos user doesn't have to deal with them. Examples are civilian gun
   ammunition or long-range fighter bombs.
   """
   */
}

