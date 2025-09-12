//
//  Type.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

public class ItemType {
  let typeId: Int64
  let groupId: Int64
  let categoryId: Int64
  let attributes: [AttrId: Double]
  let effects: [EffectId: Effect]
  let defaultEffect: Effect?
  let abilitiesData: [Int64: (Double, Int)]

  init(
    typeId: Int64,
    groupId: Int64,
    categoryId: Int64,
    attributes: [AttrId: Double],
    effects: [EffectId: Effect],
    defaultEffect: Effect?,
    abilitiesData: [Int64: (Double, Int)]
  ) {
    self.typeId = typeId
    self.groupId = groupId
    self.categoryId = categoryId
    self.attributes = attributes
    self.effects = effects
    self.defaultEffect = defaultEffect
    self.abilitiesData = abilitiesData
  }
  
  
  // @cached_property
  func effectsData() -> Any? {
    var effectsData: [String: Any] = [:]
    return nil
  }
  
  func maxState() -> State {
    var maxState: State = .offline
    for effect in effects.values {
      maxState = max(maxState, effect.state)
    }
    return maxState
  }
}
