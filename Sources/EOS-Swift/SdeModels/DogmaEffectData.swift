//
//  DogmaEffectData.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

public struct DogmaEffectData: Codable, Sendable {
  public let descriptionID: ThingName?
  public let disallowAutoRepeat: Bool
  public let displayNameID: ThingName?
  public let dischargeAttributeID: Int64?
  public let distribution: Int64?
  public let durationAttributeID: Int64?
  public let effectCategory: Int64
  public let effectID: Int64
  public let effectName: String
  public let electronicChance: Bool
  public let fittingUsageChanceAttributeID: Int64?
  public let falloffAttributeID: Int64?
  public let guid: String?
  public let iconID: Int?
  public let isAssistance: Bool
  public let isOffensive: Bool
  public let isWarpSafe: Bool
  public let modifierInfo: [ModifierData]?
  public let propulsionChance: Bool
  public let published: Bool
  public let rangeAttributeID: Int64?
  public let rangeChance: Bool
  public let trackingSpeedAttributeID: Int64?
  public let resistanceAttributeID: Int64?

  public init(
    descriptionID: String?,
    disallowAutoRepeat: Bool,
    displayNameID: String?,
    dischargeAttributeID: Int64?,
    distribution: Int64?,
    durationAttributeID: Int64?,
    effectCategory: Int64,
    effectID: Int64,
    effectName: String,
    electronicChance: Bool,
    fittingUsageChanceAttributeID: Int64?,
    falloffAttributeID: Int64?,
    guid: String?,
    iconID: Int?,
    isAssistance: Bool,
    isOffensive: Bool,
    isWarpSafe: Bool,
    modifierInfo: [ModifierData]?,
    propulsionChance: Bool,
    published: Bool,
    rangeAttributeID: Int64?,
    rangeChance: Bool,
    trackingSpeedAttributeID: Int64?,
    resistanceAttributeID: Int64?
  ) {
    if let descriptionID {
      self.descriptionID = ThingName(name: descriptionID)
    } else {
      self.descriptionID = nil
    }
    self.disallowAutoRepeat = disallowAutoRepeat

    if let displayNameID {
      self.displayNameID = ThingName(name: displayNameID)
    } else {
      self.displayNameID = nil
    }

    self.dischargeAttributeID = dischargeAttributeID
    self.distribution = distribution
    self.durationAttributeID = durationAttributeID
    self.effectCategory = effectCategory
    self.effectID = effectID
    self.effectName = effectName
    self.electronicChance = electronicChance
    self.fittingUsageChanceAttributeID = fittingUsageChanceAttributeID
    self.falloffAttributeID = falloffAttributeID
    self.guid = guid
    self.iconID = iconID
    self.isAssistance = isAssistance
    self.isOffensive = isOffensive
    self.isWarpSafe = isWarpSafe
    self.modifierInfo = modifierInfo
    self.propulsionChance = propulsionChance
    self.published = published
    self.rangeAttributeID = rangeAttributeID
    self.rangeChance = rangeChance
    self.trackingSpeedAttributeID = trackingSpeedAttributeID
    self.resistanceAttributeID = resistanceAttributeID
  }

}

public struct ModifierData: Codable, Sendable {
  public let domain: String
  public let `func`: String
  public let groupId: Int64?
  public let modifiedAttributeID: Int64?
  public let modifyingAttributeID: Int64?
  public let operation: Int64?
  public let skillTypeID: Int64?

  public init(
    domain: String,
    groupId: Int64?,
    modFunc: String,
    modifiedAttributeID: Int64?,
    modifyingAttributeID: Int64?,
    operation: Int64?,
    skillTypeID: Int64?
  ) {
    self.domain = domain
    self.func = modFunc
    self.groupId = groupId
    self.modifiedAttributeID = modifiedAttributeID
    self.modifyingAttributeID = modifyingAttributeID
    self.operation = operation
    self.skillTypeID = skillTypeID
  }
}

public struct TypeDogmaData: Codable, Sendable {
  public let dogmaAttributes: [DogmaAttributeInfo]
  public let dogmaEffects: [DogmaEffectInfo]

  public init(
    dogmaAttributes: [DogmaAttributeInfo],
    dogmaEffects: [DogmaEffectInfo] = []
  ) {
    self.dogmaAttributes = dogmaAttributes
    self.dogmaEffects = dogmaEffects
  }
}

public struct TypeDogmaDataOuter: Codable, Sendable {
  public let dogmaAttributes: [DogmaAttributeInfo]
  public let dogmaEffects: [DogmaEffectInfo]

  public init(
    dogmaAttributes: [DogmaAttributeInfo],
    dogmaEffects: [DogmaEffectInfo]
  ) {
    self.dogmaAttributes = dogmaAttributes
    self.dogmaEffects = dogmaEffects
  }
}

public struct DogmaAttributeInfo: Codable, Sendable {
  public let attributeID: Int64
  public let value: Double

  public init(attributeID: Int64, value: Double) {
    self.attributeID = attributeID
    self.value = value
  }
}

public struct DogmaEffectInfo: Codable, Sendable {
  public let effectID: Int64
  public let isDefault: Bool

  public init(effectID: Int64, isDefault: Bool) {
    self.effectID = effectID
    self.isDefault = isDefault
  }
}
