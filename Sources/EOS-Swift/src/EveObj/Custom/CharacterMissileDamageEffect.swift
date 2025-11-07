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
        affecteeAtributeId: damageAttribute.rawValue,
        modOperator: .post_mul_immune,
        aggregateMode: .stack,
        affectorAttrId: AttrId.missile_dmg_mult.rawValue
      )
    )
  }
  return Effect(
    effectId: EosEffectId.char_missile_dmg.rawValue,
    categoryID: EffectCategoryId.passive,
    isOffensive: false,
    isAssistance: false,
    buildStatus: .custom,
    modifiers: dogmaModifiers
  )
}


/*
 EffectFactory.register_class_by_id(
     ChainLightning,
     EffectId.chain_lightning)
 EffectFactory.register_class_by_id(
     ProjectileFired,
     EffectId.projectile_fired)
 EffectFactory.register_class_by_id(
     TargetDisintegratorAttack,
     EffectId.target_disintegrator_attack)
 EffectFactory.register_class_by_id(
     TargetAttack,
     EffectId.target_attack)
 */
