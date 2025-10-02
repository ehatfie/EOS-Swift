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
  func getDogmaTypeAttributes() async -> [(Int64, DogmaTypeAttributeData)]
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
  let capacity: Double?
  let mass: Double?
  let radius: Double?
  let volume: Double?
}

public struct EveGroupData: Codable, Sendable, Hashable {
  public let groupID: Int64
  public let categoryID: Int64
}

public struct DogmaTypeAttributeData: Codable, Sendable {
  let typeID: Int64
  let attributeID: Int64
  let value: Double
}

public struct DogmaTypeEffect: Sendable {
  let typeId: Int64
  let effectID: Int64
  let isDefault: Bool
}

public struct DogmaTypeEffectData: Sendable {
  let effectID: Int64
  let isDefault: Bool
}

public struct TypeSkillReq: Sendable {
  let typeId: Int64
  let skillTypeId: Int64
  let level: Int64
}


