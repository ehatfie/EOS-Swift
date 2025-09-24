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
    public let guid: String?
    public let iconID: Int?
    public let isAssistance: Bool
    public let isOffensive: Bool
    public let isWarpSafe: Bool
    public let modifierInfo: [ModifierData]?
    public let propulsionChance: Bool
    public let published: Bool
    public let rangeChance: Bool
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
