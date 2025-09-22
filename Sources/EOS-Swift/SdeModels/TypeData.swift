//
//  TypeData.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

public struct ThingName: Codable, Sendable {
  public let de: String?
  public let en: String?
  public let es: String?
  public let fr: String?
  public let ja: String?
  public let ru: String?
  public let zh: String?

  public init(name: String) {
    self.init(en: name)
  }

  internal init(
    de: String? = nil,
    en: String? = nil,
    es: String? = nil,
    fr: String? = nil,
    ja: String? = nil,
    ru: String? = nil,
    zh: String? = nil
  ) {
    self.de = de
    self.en = en
    self.es = es
    self.fr = fr
    self.ja = ja
    self.ru = ru
    self.zh = zh
  }
}

public struct TypeData: Codable, Sendable {
  public let capacity: Double?
  public let description: ThingName?
  public let graphicID: Int?
  public let groupID: Int64?
  public let iconID: Int?
  public let marketGroupID: Int?
  public let mass: Double?
  public let metaGroupID: Int?
  public let name: ThingName?
  public let portionSize: Int?
  public let published: Bool
  public let variationParentTypeID: Int?
  public let radius: Double?
  public let raceID: Int?
  public let sofFactionName: String?
  public let soundID: Int?
  public let volume: Double?

  public init(
    capacity: Double? = nil,
    description: ThingName? = nil,
    graphicID: Int? = nil,
    groupID: Int64?,
    iconID: Int? = nil,
    marketGroupID: Int? = nil,
    mass: Double? = nil,
    metaGroupID: Int? = nil,
    name: ThingName? = nil,
    portionSize: Int? = nil,
    published: Bool,
    variationParentTypeID: Int? = nil,
    radius: Double? = nil,
    raceID: Int? = nil,
    sofFactionName: String? = nil,
    soundID: Int? = nil,
    volume: Double? = nil
  ) {
    self.capacity = capacity
    self.description = description
    self.graphicID = graphicID
    self.groupID = groupID
    self.iconID = iconID
    self.marketGroupID = marketGroupID
    self.mass = mass
    self.metaGroupID = metaGroupID
    self.name = name
    self.portionSize = portionSize
    self.published = published
    self.variationParentTypeID = variationParentTypeID
    self.radius = radius
    self.raceID = raceID
    self.sofFactionName = sofFactionName
    self.soundID = soundID
    self.volume = volume
  }
}
