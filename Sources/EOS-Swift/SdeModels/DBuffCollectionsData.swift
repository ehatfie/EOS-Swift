//
//  DBuffCollectionsData.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//


public struct DBuffCollectionsData: Codable, Sendable {
  let aggregateMode: String
  let developerDescription: String
  let displayName: ThingName?
  let itemModifiers: [ItemModifiersData]
  let locationGroupModifiers: [ItemModifiersData]
  let locationModifiers: [ItemModifiersData]
  let locationRequiredSkillModifiers: [ItemModifiersData]
  let operationName: String
  let showOutputValueInUI: String
}

struct ItemModifiersData: Codable {
  let dogmaAttributeID: Int64
  let groupID: Int64?
  let skillID: Int64?
}
