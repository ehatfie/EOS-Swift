//
//  TankingMixin.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public protocol BufferTankingMixinProtocol: BaseItemMixinProtocol {
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
  public var hp: ItemHP {
    print(".. attributes1 \(self.attributes)")
    let hull = self.attributes![AttrId.hp.rawValue, default: 0]
    let armor = self.attributes![AttrId.armor_hp.rawValue, default: 0]
    let shield = self.attributes![AttrId.shield_capacity.rawValue, default: 0]
    
    return ItemHP(hull: hull, armor: armor, shield: shield)
  }
  
  public var resists: TankingLayers<ResistProfile> {
    print("++ get resists")
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
  
  public var worstCaseEHP: ItemHP {
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
  
  public func getResistByAttribute(_ attribute: AttrId) -> Double {
    return getResistByAttribute(attributeID: attribute)
  }
  
  public func getResistByAttribute(attributeID: AttrId) -> Double {
    guard let attributes = self.attributes else {
      return 1
    }
    let attributeValue = attributes[attributeID.rawValue, default: 1]
    return 1 - attributeValue
  }
  
  public func getEHP(damageProfile: DamageProfile?) -> ItemHP {
    let fitDefault = self.fit?.defaultIncomingDamage
    
    let maybeDamageProfile = damageProfile ?? self.fit?.defaultIncomingDamage
    guard let actualDamageProfile = damageProfile ?? fitDefault else {
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
    print("++ returning h: \(hullEHP) a: \(armorEHP) s: \(shieldEHP)")
    return ItemHP(hull: hullEHP, armor: armorEHP, shield: shieldEHP)
  }
  
  // layerHp might be nil?
  /// Calculate layer EHP according to passed data.
  /// If layer raw HP is None, None is returned.
  public func getLayerEHP(layerHp: Double, layerResists: ResistProfile, damageProfile: DamageProfile) -> Double {
    let tankMult = self.getTankingEfficiency(
      damageProfile: damageProfile,
      resists: layerResists
    )
    return layerHp * tankMult
  }
  
  /// Get tanking efficiency for passed damage/resistance profiles.
  /// If any of layer resistances are not specified, they're assumed to be 0.
  public func getTankingEfficiency(damageProfile: DamageProfile, resists: ResistProfile) -> Double {
    let dealt = damageProfile.em + damageProfile.thermal + damageProfile.kinetic + damageProfile.explosive
    let absorbed = (damageProfile.em * resists.em) + (damageProfile.thermal * resists.thermal) + (damageProfile.kinetic * resists.kinetic) + (damageProfile.explosive * resists.explosive)
    let recieved = dealt - absorbed
    print("^^ getTankingEfficiency: dealt: \(dealt) absorbed: \(absorbed) recieved: \(recieved)")
    return dealt / recieved
  }
  
  public func getLayerWorstCaseEHP(layerHp: Double, layerResists: ResistProfile) -> Double {
    0.0
  }

}

public class BufferTankingMixin: BaseItemMixin, BufferTankingMixinProtocol {
  public var resists: TankingLayers<ResistProfile> {
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
  
  public var worstCaseEHP: ItemHP {
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
  
  public func getResistByAttribute(_ attribute: AttrId) -> Double {
    return getResistByAttribute(attributeID: attribute)
  }
  
  public func getResistByAttribute(attributeID: AttrId) -> Double {
    return 1 - self.attributes![attributeID.rawValue, default: 1]
  }
  
  public func getEHP(damageProfile: DamageProfile?) -> ItemHP {
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
  public func getLayerEHP(layerHp: Double, layerResists: ResistProfile, damageProfile: DamageProfile) -> Double {
    print("^^ BTM - getLayerEHP")
    let tankMult = self.getTankingEfficiency(
      damageProfile: damageProfile,
      resists: layerResists
    )
    print("^^ layerHp: \(layerHp) tankMult: \(tankMult)")
    return layerHp * tankMult
  }
  
  /// Get tanking efficiency for passed damage/resistance profiles.
  /// If any of layer resistances are not specified, they're assumed to be 0.
  public func getTankingEfficiency(damageProfile: DamageProfile, resists: ResistProfile) -> Double {
    let dealt = damageProfile.em + damageProfile.thermal + damageProfile.kinetic + damageProfile.explosive
    let absorbed = (damageProfile.em * resists.em) + (damageProfile.thermal * resists.thermal) + (damageProfile.kinetic * resists.kinetic) + (damageProfile.explosive * resists.explosive)
    let recieved = dealt - absorbed
    return dealt / recieved
  }
  
  /// Calculate layer EHP according to passed data.
  /// If layer raw HP is None, None is returned.
  public func getLayerWorstCaseEHP(layerHp: Double, layerResists: ResistProfile) -> Double {
    if layerHp.isZero {
      return 0
    }
    
    let resist = min(layerResists.em, layerResists.thermal, layerResists.kinetic, layerResists.explosive)

    return layerHp / (1 - resist)
  }
  
  public var hp: ItemHP {
    print(".. attributes \(self.attributes)")
    let hull = self.attributes![AttrId.hp.rawValue, default: 0]
    let armor = self.attributes![AttrId.armor_hp.rawValue, default: 0]
    let shield = self.attributes![AttrId.shield_capacity.rawValue, default: 0]
    
    return ItemHP(hull: hull, armor: armor, shield: shield)
  }
}
