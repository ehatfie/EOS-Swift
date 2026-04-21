//
//  EffectHelperFunc.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

import Foundation

// not sure if necessary
//let keep_digits = int(sys.float_info.dig / 2)


func floatToInt(value: Float) -> Int {
  //Convert number to integer, taking care of float errors.
  // if we want to use keepDigits we would need to do something like
  // TODO: Verify
  return Int(round(value))
}

// maybe could return Int
func getCyclesUntilReloadGeneric(item: BaseItemMixin, defaultVal: Double? = nil) -> Double {
  // TODO
  /*
   """Get cycles until reload for items with regular charge mechanics."""
   charge_quantity = item.charge_quantity
   if charge_quantity is None:
       return default
   charge_rate = item.attrs.get(AttrId.charge_rate)
   if not charge_rate:
       return default
   cycles = charge_quantity // int(charge_rate)
   if cycles == 0:
       return default
   return cycles
   */
  //let chargeQuantity = item.chargeQuantity
  guard let module = item as? Module else {
    return defaultVal ?? 0
  }
  guard let chargeQuantity = module.chargeQuantity else {
    return defaultVal ?? 0.0
  }
  guard let chargeRate = module.attributes?.getValue(attributeId: .charge_rate) else {
    print("!! no charge rate")
    return defaultVal ?? 0.0
  }
  // this should round down ie 3.3 -> 3
  let cycles = Int(chargeQuantity / Double(chargeRate))
  if cycles == 0 {
    return defaultVal ?? 0.0
  }

  return Double(cycles)
}


/*
 def get_cycles_until_reload_crystal(item, default=None):
     """Get cycles until reload for items which use crystals as charge."""
     charge_quantity = item.charge_quantity
     if not charge_quantity:
         return default
     charge = item.charge
     # Non-damageable crystals can cycle infinitely
     if not charge.attrs.get(AttrId.crystals_get_damaged):
         return math.inf
     # Damageable crystals must have all damage-related stats to calculate how
     # many times they can cycle
     try:
         hp = charge.attrs[AttrId.hp]
         chance = charge.attrs[AttrId.crystal_volatility_chance]
         dmg = charge.attrs[AttrId.crystal_volatility_dmg]
     except KeyError:
         return default
     if hp <= 0:
         return default
     if chance <= 0 or dmg <= 0:
         return math.inf
     cycles = float_to_int(hp / dmg / chance) * charge_quantity
     if cycles == 0:
         return default
     return cycles
 */

/// Get cycles until reload for items which use crystals as charge.
func getCyclesUntilReloadCrystals(item: Module, defaultVal: Double? = nil) -> Double {
  guard let chargeQuantity = item.chargeQuantity else {
    return defaultVal ?? 0.0
  }

  guard let charge = item.charge.item else {
    print("!! no charge")
    return defaultVal ?? 0.0
  }
  
  // Non-damageable crystals can cycle infinitely
  if charge.attributes?.getValue(attributeId: .crystals_get_damaged) == nil {
    return .infinity
  }
  
  //Damageable crystals must have all damage-related stats to calculate how many times they can cycle
  guard
    let hp = charge.attributes?.getValue(attributeId: .hp),
    let chance = charge.attributes?.getValue(attributeId: .crystal_volatility_chance),
    let damage = charge.attributes?.getValue(attributeId: .crystal_volatility_dmg) else {
    print("!! not enough crystal info")
    return defaultVal ?? 0.0
  }
  
  if hp <= 0 {
    return defaultVal ?? 0.0
  }
  if chance <= 0 || damage <= 0 {
    return .infinity
  }
  
  let cycles = Int(hp / damage / chance) * Int(chargeQuantity)
  return Double(cycles)
}
