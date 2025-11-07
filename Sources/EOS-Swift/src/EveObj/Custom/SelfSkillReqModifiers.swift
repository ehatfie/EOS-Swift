//
//  SelfSkillReqModifiers.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/16/25.
//


func makeMissileROFModifiers() -> [DogmaModifier] {
  return [
    DogmaModifier(
      affecteeFilter: .domain_skillrq,
      affecteeFilterExtraArg: Int64(EosTypeId.current_self.rawValue),
      affecteeDomain: .ship,
      affecteeAtributeId: AttrId.speed.rawValue,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: AttrId.rof_bonus.rawValue
    )
  ]
}

func makeMissileDMGModifiers(affecteeAttributeId: AttrId) -> [DogmaModifier] {
  return [
    DogmaModifier(
      affecteeFilter: .owner_skillrq,
      affecteeFilterExtraArg: Int64(EosTypeId.current_self.rawValue),
      affecteeDomain: .character,
      affecteeAtributeId: affecteeAttributeId.rawValue,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: AttrId.dmg_mult_bonus.rawValue
    )
  ]
}


func makeDroneDMGModifiers() -> [DogmaModifier] {
  return [
    DogmaModifier(
      affecteeFilter: .owner_skillrq,
      affecteeFilterExtraArg: Int64(EosTypeId.current_self.rawValue),
      affecteeDomain: .character,
      affecteeAtributeId: AttrId.dmg_mult.rawValue,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: AttrId.dmg_mult_bonus.rawValue
    )
  ]
}
