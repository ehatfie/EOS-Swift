//
//  EffectBeacon.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

protocol EffectBeaconProtocol: ImmutableStateMixinProtocol {
  
}

class EffectBeacon: ImmutableStateMixin {
  
  init(typeId: Int64) {
    super.init(typeId: typeId, state: .offline)
    
    self.modifierDomain = .me
    self.ownerModifiable = false
    self.solsysCarrier = nil
  }
}

/*
 class EffectBeacon(ImmutableStateMixin):
     """Represents an effect beacon.

     Effect beacons in eve are item which carries system-wide anomaly effects.

     Args:
         type_id: Identifier of item type which should serve as base for this
             effect beacon.
     """

     def __init__(self, type_id):
         super().__init__(type_id=type_id, state=State.offline)

     # Attribute calculation-related properties
     _modifier_domain = None
     _owner_modifiable = False
     _solsys_carrier = None

     # Auxiliary methods
     def __repr__(self):
         spec = [['type_id', '_type_id']]
         return make_repr_str(self, spec)
 */
