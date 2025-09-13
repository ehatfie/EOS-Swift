//
//  Ship.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//
import Foundation

// Might be worth sticking to the BaseItemMixin implementation
class Ship:
  BaseItemMixin,
  ImmutableStateMixinProtocol,
  BufferTankingMixinProtocol,
  SolarSystemMixinProtocol
{
//  var modifierDomain: ModDomain?
//  
//  var ownerModifiable: Bool
//  
//  var solsysCarrier: Any?
//  
//  var attributes: [Int64 : Double] = [:]
//  
//  var typeId: Int64
//  
//  var itemType: ItemType? = nil
//  
//  var container: (any ItemContainerBaseProtocol)? = nil
//  
//  var runningEffectIds: Set<EffectId> = []
//  
//  var effectModeOverrides: [EffectId : EffectMode]? = nil
//  
//  var effectTargets: String? = nil
//  
//  var _state: State
//  
//  var fit: Fit? = nil
  
  //var resists: TankingLayers<ResistProfile>
  
  //var worstCaseEHP: ItemHP
  
  var coordinate: CGSize = .init(width: 0, height: 0)
  
  var orientation: CGSize = .init(width: 0, height: 0)
  
  override init(typeId: Int64, state: State) {
    super.init(typeId: typeId, state: state)
    self.modifierDomain = .ship
    self.ownerModifiable = true
  }
}

//extension Ship: BufferTankingMixin {
//  
//}
//
//extension Ship: SolarSystemMixin {
//  
//}
