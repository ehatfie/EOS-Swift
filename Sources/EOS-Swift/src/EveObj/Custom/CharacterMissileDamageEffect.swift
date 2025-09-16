//
//  CharacterMissileDamageEffect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//



func makeMissileDamageEffect() -> Effect {
  
  let damageAttributes: [AttrId] = [
    .em_dmg,
    .therm_dmg,
    .kin_dmg,
    .expl_dmg
  ]
  var dogmaModifiers: [DogmaModifier] = []
  for damageAttribute in damageAttributes {
    dogmaModifiers.append(
      DogmaModifier(
        affecteeFilter: .owner_skillrq,
        affecteeFilterExtraArg: TypeId.missileLauncherOperation.rawValue,
        affecteeDomain: .character,
        affecteeAtributeId: damageAttribute,
        modOperator: .post_mul_immune,
        aggregateMode: .stack,
        affectorAttrId: .missile_dmg_mult
      )
    )
  }
  return Effect(
    effectId: EosEffectId.char_missile_dmg.rawValue,
    categoryID: EffectCategoryId.passive.rawValue,
    isOffensive: false,
    isAssistance: false,
    buildStatus: .custom,
    modifiers: dogmaModifiers
  )
}
