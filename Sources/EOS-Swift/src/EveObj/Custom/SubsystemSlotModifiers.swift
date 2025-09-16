//
//  SubsystemSlotModifiers.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/16/25.
//


func makeSlotModifiers() -> [DogmaModifier] {
  
  var values: [(AttrId, AttrId)] = [
    (.hi_slot_modifier, .hi_slots),
    (.med_slot_modifier, .med_slots),
    (.low_slot_modifier, .low_slots)
  ]
  var returnValues: [DogmaModifier] = []
  
  for (affectorAttributeId, affecteeAttributeId) in values {
    returnValues.append(
      DogmaModifier(
        affecteeFilter: .item,
        affecteeDomain: .ship,
        affecteeAtributeId: affecteeAttributeId,
        modOperator: .mod_add,
        aggregateMode: .stack,
        affectorAttrId: affectorAttributeId
      )
    )
  }
  
  return returnValues
}

func makeHardpointModifiers() -> [DogmaModifier] {
  
  var values: [(AttrId, AttrId)] = [
    (.turret_hardpoint_modifier, .turret_slots_left),
    (.launcher_hardpoint_modifier, .launcher_slots_left)
  ]
  var returnValues: [DogmaModifier] = []
  
  for (affectorAttributeId, affecteeAttributeId) in values {
    returnValues.append(
      DogmaModifier(
        affecteeFilter: .item,
        affecteeDomain: .ship,
        affecteeAtributeId: affecteeAttributeId,
        modOperator: .mod_add,
        aggregateMode: .stack,
        affectorAttrId: affectorAttributeId
      )
    )
  }
  
  return returnValues
}
