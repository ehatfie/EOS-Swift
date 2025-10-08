//
//  Base.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

/*
  Data handlers fetch 'raw' data from external source. Its abstract methods
  are named against data structures (usually tables) they request, returning
  iterable with rows, each row being dictionary in {field name: field value} format.
 */
public protocol DataHandlerProtocol {
  func getEveTypes() async -> [EveTypeData]
  func getEveGroups() async -> [EveGroupData]
  func getDogmaAttributes() async -> [DogmaAttributeData]
  func getDogmaTypeAttributes() async -> [DogmaTypeAttributeData]
  func getDogmaEffects() async -> [DogmaEffectData]
  func getDogmaTypeEffects() async -> [DogmaTypeEffect]
  func getDebuffCollection() async -> [DBuffCollectionsData]
  func getSkillReqs() async -> [TypeSkillReq]
  func getTypeFighterabils()
  func getVersion() -> String?
}

public struct EveTypeData: Codable, Sendable {
  public let typeID: Int64
  public let groupID: Int64?
  public let capacity: Double?
  public let mass: Double?
  public let radius: Double?
  public let volume: Double?

  public init(
    typeID: Int64,
    groupID: Int64?,
    capacity: Double?,
    mass: Double?,
    radius: Double?,
    volume: Double?
  ) {
    self.typeID = typeID
    self.groupID = groupID
    self.capacity = capacity
    self.mass = mass
    self.radius = radius
    self.volume = volume
  }
}

public struct EveGroupData: Codable, Sendable, Hashable {
  public let groupID: Int64
  public let categoryID: Int64
  
  public init(groupID: Int64, categoryID: Int64) {
    self.groupID = groupID
    self.categoryID = categoryID
  }
}

public struct DogmaTypeAttributeData: Codable, Sendable {
  public let typeID: Int64
  public let attributeID: Int64
  public let value: Double
  
  public init(typeID: Int64, attributeID: Int64, value: Double) {
    self.typeID = typeID
    self.attributeID = attributeID
    self.value = value
  }
}

public struct TypeDogmaAttributeDataOuter: Codable, Sendable {
  let dogmaAttributes: [TypeDogmaAttributeData]
  let dogmaEffects: [DogmaTypeEffectData]?
}

public struct TypeDogmaAttributeData: Codable, Sendable {
  let attributeID: Int64
  let value: Double
  
  public init(attributeID: Int64, value: Double) {
    self.attributeID = attributeID
    self.value = value
  }
}

public struct DogmaTypeEffect: Sendable {
  let typeId: Int64
  let effectID: Int64
  let isDefault: Bool
  
  public init(typeId: Int64, effectID: Int64, isDefault: Bool) {
    self.typeId = typeId
    self.effectID = effectID
    self.isDefault = isDefault
  }
}

public struct DogmaTypeEffectData: Codable, Sendable {
  let effectID: Int64
  let isDefault: Bool
}

public struct TypeSkillReq: Sendable {
  let typeId: Int64
  let skillTypeId: Int64
  let level: Int64
  
  public init(typeId: Int64, skillTypeId: Int64, level: Int64) {
    self.typeId = typeId
    self.skillTypeId = skillTypeId
    self.level = level
  }
}
