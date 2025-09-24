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

}

public struct ModifierData: Codable, Sendable {
  public let domain: String
  public let `func`: String
  public let groupId: Int64?
  public let modifiedAttributeID: Int64?
  public let modifyingAttributeID: Int64?
  public let operation: Int64?
  public let skillTypeID: Int64?
}

public struct TypeDogmaData: Codable, Sendable {
    public let dogmaAttributes: [DogmaAttributeInfo]
    public let dogmaEffects: [DogmaEffectInfo]
    
    public init(dogmaAttributes: [DogmaAttributeInfo], dogmaEffects: [DogmaEffectInfo]) {
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
