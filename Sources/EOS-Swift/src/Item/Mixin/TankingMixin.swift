//
//  TankingMixin.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

protocol BufferTankingMixinProtocol: BaseItemMixinProtocol {
  var hp: ItemHP { get }
  var resists: TankingLayers<ResistProfile> { get }
  var worstCaseEHP: ItemHP { get }
  
  func getResistByAttribute(attributeID: AttrId) -> Double
  func getEHP(damageProfile: DamageProfile?) -> ItemHP
  func getLayerEHP(layerHp: Double, layerResists: ResistProfile,damageProfile: DamageProfile) -> Double
  func getTankingEfficiency(damageProfile: DamageProfile, resists: ResistProfile) -> Double
  func getLayerWorstCaseEHP(layerHp: Double, layerResists: ResistProfile) -> Double
}

extension BufferTankingMixinProtocol {
  var hp: ItemHP {
    let hull = self.attributes[AttrId.hp, default: 0]
    let armor = self.attributes[AttrId.armor_hp, default: 0]
    let shield = self.attributes[AttrId.shield_capacity, default: 0]
    
    return ItemHP(hull: hull, armor: armor, shield: shield)
  }
  
  var resists: TankingLayers<ResistProfile> {
    let hull: ResistProfile = ResistProfile(
      self.getResistByAttribute(.em_dmg_resonance),
      thermal: self.getResistByAttribute(.therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.kin_dmg_resonance),
      explosive: self.getResistByAttribute(.expl_dmg_resonance)
    ) ?? .emptyValue
    
    let armor: ResistProfile = ResistProfile(
      self.getResistByAttribute(.armor_em_dmg_resonance),
      thermal: self.getResistByAttribute(.armor_therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.armor_kin_dmg_resonance),
      explosive: self.getResistByAttribute(.armor_expl_dmg_resonance)
    ) ?? .emptyValue
    
    let shield: ResistProfile = ResistProfile(
      self.getResistByAttribute(.shield_em_dmg_resonance),
      thermal: self.getResistByAttribute(.shield_therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.shield_kin_dmg_resonance),
      explosive: self.getResistByAttribute(.shield_expl_dmg_resonance)
    ) ?? .emptyValue
    
    return TankingLayers<ResistProfile>(hull: hull, armor: armor, shield: shield)
  }
  
  var worstCaseEHP: ItemHP {
    let hullEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.hull,
      layerResists: self.resists.hull
    )
    let armorEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.armor,
      layerResists: self.resists.armor
    )
    let shieldEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.shield,
      layerResists: self.resists.shield
    )
    return ItemHP(hull: hullEHP, armor: armorEHP, shield: shieldEHP)
  }
  
  func getResistByAttribute(_ attribute: AttrId) -> Double {
    return getResistByAttribute(attributeID: attribute)
  }
  
  func getResistByAttribute(attributeID: AttrId) -> Double {
    return 1 - self.attributes[attributeID, default: 1]
  }
  
  func getEHP(damageProfile: DamageProfile?) -> ItemHP {
    let maybeDamageProfile = damageProfile ?? self.fit?.defaultIncomingDamage
    guard let actualDamageProfile = damageProfile else {
      return .init(hull: 0, armor: 0, shield: 0)
    }
    
    let hullEHP: Double = getLayerEHP(
      layerHp: self.hp.hull,
      layerResists: self.resists.hull,
      damageProfile: actualDamageProfile
    )
    
    let armorEHP: Double = getLayerEHP(
      layerHp: self.hp.armor,
      layerResists: self.resists.armor,
      damageProfile: actualDamageProfile
    )
    
    let shieldEHP: Double = getLayerEHP(
      layerHp: self.hp.shield,
      layerResists: self.resists.shield,
      damageProfile: actualDamageProfile
    )
    
    return ItemHP(hull: hullEHP, armor: armorEHP, shield: shieldEHP)
  }
  
  // layerHp might be nil?
  /// Calculate layer EHP according to passed data.
  /// If layer raw HP is None, None is returned.
  func getLayerEHP(layerHp: Double, layerResists: ResistProfile, damageProfile: DamageProfile) -> Double {
    let tankMult = self.getTankingEfficiency(
      damageProfile: damageProfile,
      resists: layerResists
    )
    return layerHp * tankMult
  }
  
  /// Get tanking efficiency for passed damage/resistance profiles.
  /// If any of layer resistances are not specified, they're assumed to be 0.
  func getTankingEfficiency(damageProfile: DamageProfile, resists: ResistProfile) -> Double {
    let dealt = damageProfile.em + damageProfile.thermal + damageProfile.kinetic + damageProfile.explosive
    let absorbed = (damageProfile.em * resists.em) + (damageProfile.thermal * resists.thermal) + (damageProfile.kinetic * resists.kinetic) + (damageProfile.explosive * resists.explosive)
    let recieved = dealt - absorbed
    return dealt / recieved
  }
  
  func getLayerWorstCaseEHP(layerHp: Double, layerResists: ResistProfile) -> Double {
    0.0
  }

}

class BufferTankingMixin: BaseItemMixin, BufferTankingMixinProtocol {
  var resists: TankingLayers<ResistProfile> {
    let hull: ResistProfile = ResistProfile(
      self.getResistByAttribute(.em_dmg_resonance),
      thermal: self.getResistByAttribute(.therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.kin_dmg_resonance),
      explosive: self.getResistByAttribute(.expl_dmg_resonance)
    ) ?? .emptyValue
    
    let armor: ResistProfile = ResistProfile(
      self.getResistByAttribute(.armor_em_dmg_resonance),
      thermal: self.getResistByAttribute(.armor_therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.armor_kin_dmg_resonance),
      explosive: self.getResistByAttribute(.armor_expl_dmg_resonance)
    ) ?? .emptyValue
    
    let shield: ResistProfile = ResistProfile(
      self.getResistByAttribute(.shield_em_dmg_resonance),
      thermal: self.getResistByAttribute(.shield_therm_dmg_resonance),
      kinetic: self.getResistByAttribute(.shield_kin_dmg_resonance),
      explosive: self.getResistByAttribute(.shield_expl_dmg_resonance)
    ) ?? .emptyValue
    
    return TankingLayers<ResistProfile>(hull: hull, armor: armor, shield: shield)
  }
  
  var worstCaseEHP: ItemHP {
    let hullEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.hull,
      layerResists: self.resists.hull
    )
    let armorEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.armor,
      layerResists: self.resists.armor
    )
    let shieldEHP: Double = self.getLayerWorstCaseEHP(
      layerHp: self.hp.shield,
      layerResists: self.resists.shield
    )
    return ItemHP(hull: hullEHP, armor: armorEHP, shield: shieldEHP)
  }
  
  func getResistByAttribute(_ attribute: AttrId) -> Double {
    return getResistByAttribute(attributeID: attribute)
  }
  
  func getResistByAttribute(attributeID: AttrId) -> Double {
    return 1 - self.attributes[attributeID, default: 1]
  }
  
  func getEHP(damageProfile: DamageProfile?) -> ItemHP {
    let maybeDamageProfile = damageProfile ?? self.fit?.defaultIncomingDamage
    guard let actualDamageProfile = damageProfile else {
      return .init(hull: 0, armor: 0, shield: 0)
    }
    
    let hullEHP: Double = getLayerEHP(
      layerHp: self.hp.hull,
      layerResists: self.resists.hull,
      damageProfile: actualDamageProfile
    )
    
    let armorEHP: Double = getLayerEHP(
      layerHp: self.hp.armor,
      layerResists: self.resists.armor,
      damageProfile: actualDamageProfile
    )
    
    let shieldEHP: Double = getLayerEHP(
      layerHp: self.hp.shield,
      layerResists: self.resists.shield,
      damageProfile: actualDamageProfile
    )
    
    return ItemHP(hull: hullEHP, armor: armorEHP, shield: shieldEHP)
  }
  
  // layerHp might be nil?
  /// Calculate layer EHP according to passed data.
  /// If layer raw HP is None, None is returned.
  func getLayerEHP(layerHp: Double, layerResists: ResistProfile, damageProfile: DamageProfile) -> Double {
    let tankMult = self.getTankingEfficiency(
      damageProfile: damageProfile,
      resists: layerResists
    )
    return layerHp * tankMult
  }
  
  /// Get tanking efficiency for passed damage/resistance profiles.
  /// If any of layer resistances are not specified, they're assumed to be 0.
  func getTankingEfficiency(damageProfile: DamageProfile, resists: ResistProfile) -> Double {
    let dealt = damageProfile.em + damageProfile.thermal + damageProfile.kinetic + damageProfile.explosive
    let absorbed = (damageProfile.em * resists.em) + (damageProfile.thermal * resists.thermal) + (damageProfile.kinetic * resists.kinetic) + (damageProfile.explosive * resists.explosive)
    let recieved = dealt - absorbed
    return dealt / recieved
  }
  
  func getLayerWorstCaseEHP(layerHp: Double, layerResists: ResistProfile) -> Double {
    0.0
  }
  
  var hp: ItemHP {
    let hull = self.attributes[AttrId.hp, default: 0]
    let armor = self.attributes[AttrId.armor_hp, default: 0]
    let shield = self.attributes[AttrId.shield_capacity, default: 0]
    
    return ItemHP(hull: hull, armor: armor, shield: shield)
  }
}
