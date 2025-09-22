//
//  DogmaAttributeData.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

public struct DogmaAttributeData: Codable, Sendable {
  public let attributeID: Int64
  public let categoryID: Int64?
  public let dataType: Int
  public let defaultValue: Double
  public let description: String?
  public let displayNameID: ThingName?
  public let highIsGood: Bool
  public let iconID: Int?
  public let name: String
  public let published: Bool
  public let stackable: Bool
  public let tooltipDescriptionID: ThingName?
  public let tooltipTitleID: ThingName?
  public let unitID: Int?

  public init(
    attributeID: Int64,
    categoryID: Int64? = nil,
    dataType: Int = 0,
    defaultValue: Double,
    description: String?,
    displayNameID: ThingName? = nil,
    highIsGood: Bool = true,
    iconID: Int? = nil,
    name: String,
    published: Bool = false,
    stackable: Bool = false,
    tooltipDescriptionID: ThingName? = nil,
    tooltipTitleID: ThingName? = nil,
    unitID: Int? = nil
  ) {
    self.attributeID = attributeID
    self.categoryID = categoryID
    self.dataType = dataType
    self.defaultValue = defaultValue
    self.description = description
    self.displayNameID = displayNameID
    self.highIsGood = highIsGood
    self.iconID = iconID
    self.name = name
    self.published = published
    self.stackable = stackable
    self.tooltipDescriptionID = tooltipDescriptionID
    self.tooltipTitleID = tooltipTitleID
    self.unitID = unitID
  }
}
