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
protocol DataHandlerProtocol {
  func getEveTypes() async -> [EveTypeData]
  
  func getEveGroups() async -> [EveGroupData]
  func getDogmaAttributes() async -> [DogmaAttributeData]
  func getDogmaTypeAttributes() async -> [DogmaTypeAttributeData]
  func getDogmaEffects() async -> [DogmaEffectData]
  func getDogmaTypeEffects() async -> [DogmaTypeEffect]
  func getDebuffCollection() async -> [DBuffCollectionsData]
  func getSkillReqs() async -> [TypeSkillReq]
  func getTypeFighterabils()
  func getVersion() -> String
}

struct EveTypeData: Codable {
  let typeID: Int64
  let groupID: Int64
  let capacity: Double
  let mass: Double
  let radius: Double
  let volume: Double
}

struct EveGroupData: Codable {
  let groupID: Int64
  let categoryID: Int64
}

struct DogmaTypeAttributeData: Codable {
  let typeID: Int64
  let attributeID: Int64
  let value: Double
}

struct DogmaTypeEffect {
  let typeId: Int64
  let effectID: Int64
  let isDefault: Bool
}

struct DogmaTypeEffectData {
  let effectID: Int64
  let isDefault: Bool
}

struct TypeSkillReq {
  let typeId: Int64
  let skillTypeId: Int64
  let level: Int64
}
