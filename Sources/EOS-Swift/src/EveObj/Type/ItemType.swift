//
//  Type.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public class ItemType {
  public let name: String
  let typeId: Int64
  let groupId: Int64
  let categoryId: Int64
  let attributes: [Int64: Double]
  let effects: [Int64: Effect]
  let defaultEffect: Effect?
  let abilitiesData: [Int64: (Double, Int)]
  let requiredSkills: [Int64: Int64]

  init(
    name: String,
    typeId: Int64,
    groupId: Int64,
    categoryId: Int64,
    attributes: [Int64: Double],
    effects: [Int64: Effect],
    defaultEffect: Effect?,
    abilitiesData: [Int64: (Double, Int)],
    requiredSkills: [Int64: Int64] = [:]
  ) {
    self.name = name
    self.typeId = typeId
    self.groupId = groupId
    self.categoryId = categoryId
    //print("** ItemType init \(typeId) \(attributes)")
    self.attributes = attributes
    self.effects = effects
    self.defaultEffect = defaultEffect
    self.abilitiesData = abilitiesData
    self.requiredSkills = requiredSkills
  }
  
  
  // @cached_property
  func effectsData() -> Any? {
    var effectsData: [String: Any] = [:]
    return nil
  }
  
  func maxState() -> StateI {
    var maxState: StateI = .offline
    for effect in effects {
      maxState = max(maxState, effect.value.state)
    }
    return maxState
  }
}
