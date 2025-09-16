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
      affecteeAtributeId: .speed,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: .rof_bonus
    )
  ]
}

func makeMissileDMGModifiers(affecteeAttributeId: AttrId) -> [DogmaModifier] {
  return [
    DogmaModifier(
      affecteeFilter: .owner_skillrq,
      affecteeFilterExtraArg: Int64(EosTypeId.current_self.rawValue),
      affecteeDomain: .character,
      affecteeAtributeId: affecteeAttributeId,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: .dmg_mult_bonus
    )
  ]
}


func makeDroneDMGModifiers() -> [DogmaModifier] {
  return [
    DogmaModifier(
      affecteeFilter: .owner_skillrq,
      affecteeFilterExtraArg: Int64(EosTypeId.current_self.rawValue),
      affecteeDomain: .character,
      affecteeAtributeId: .dmg_mult,
      modOperator: .post_percent,
      aggregateMode: .stack,
      affectorAttrId: .dmg_mult_bonus
    )
  ]
}
