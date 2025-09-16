//
//  ReactiveArmorHardener.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/16/25.
//

func makeRAHModifiers() -> [DogmaModifier] {
  var modifiers: [DogmaModifier] = []
  for attributeId in [
    AttrId.armor_em_dmg_resonance,
    AttrId.armor_therm_dmg_resonance,
    AttrId.armor_kin_dmg_resonance,
    AttrId.armor_expl_dmg_resonance
  ] {
    modifiers.append(
      DogmaModifier(
        affecteeFilter: .item,
        affecteeDomain: .ship,
        affecteeAtributeId: attributeId,
        modOperator: .pre_mul,
        aggregateMode: .stack,
        affectorAttrId: attributeId,
      )
    )
  }

  return modifiers
}
