//
//  eos.swift
//  EOS-Swift
//
//
//  Created by Erik Hatfield on 8/31/25.
//  https://github.com/pyfa-org/eos/blob/master/eos/const/eos.py

/*
This file holds IDs of multiple Eos-specific entities.
*/

public enum StateI: Int, Codable, CaseIterable {
  /*
   Contains possible item states.
  
  Also used as effects' attribute to determine when this effect should be run.
  
   Values assigned to states are not deliberate, they must be in ascending
  // order. It means that e.g. online module state, which should trigger
  // modules' online and offline effects/modifiers, must have higher value
  // than offline, and so on.
   */
  case offline = 1
  case online = 2
  case active = 3
  case overload = 4
}

extension StateI: Comparable {
  public static func < (lhs: StateI, rhs: StateI) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

public enum EffectMode: Int {
  /*
   Contains possible effect run modes.
  
   Run modes define under which conditions effects are run.
   */
  // In this mode rules vary, depending on effect category:
  // - Offline: effects from this category are run when item is in offline+
  // state, and when they do not have fitting usage chance specified
  // - Online: effects from this category are run when item is in online+
  // state, and when item has runnable 'online' effect
  // - Active: effects from this category are run when item is in active+
  // state, and only when effect is default item effect
  // - Overload: effects from this category are run when item is in overload+
  // state
  case full_compliance = 1
  // Effects in this mode are always run if item's state is high enough to run
  // it
  case state_compliance = 2
  // Effects in this mode are always running no matter what
  case force_run = 3
  // Effects in this mode are never running no matter what
  case force_stop = 4
}

enum EffectBuildStatus: Int, Codable {
  /*
   Contains possible effect build statuses.
  
  Used for informational purposes only.
  */
  case skipped = 1
  case error = 2
  case success_partial = 3
  case success = 4
  case custom = 5
}

enum ModAffecteeFilter: Int, CaseIterable {
  /*
  Contains possible modifier target filter types.
  
    Used during attribute calculation.
    */
  case item = 1
  case domain = 2  // Domain children only, excluding parent item
  case domain_group = 3  // Domain children only, excluding parent item
  case domain_skillrq = 4  // Domain children only, excluding parent item
  case owner_skillrq = 5
  
  init?(value: String) {
    switch value {
    case "ItemModifier": self = .item
    case "LocationModifier": self = .domain
    case "LocationGroupModifier": self = .domain_group
    case "LocationRequiredSkillModifier": self = .domain_skillrq
    case "OwnerRequiredSkillModifier": self = .owner_skillrq
    default: return nil
    }
  }
}

public enum ModDomain: Int, CaseIterable {
  /*
   Contains possible modifier domains.
  
   Used during attribute calculation.
   */
  case me = 1  // Self, i.e. item modification source belongs to
  case character = 2
  case ship = 3
  case target = 4
  case other = 5  // Module for charge, charge for module
  
  init?(value: String) {
    switch value {
    case "itemID": self = .me
    case "charID": self = .character
    case "shipID": self = .ship
    case "targetID": self = .target
    case "other": self = .other
    
    default: return nil
    }
  }
}

enum ModOperator: Int, CaseIterable, Sendable, Hashable {

  /*
   Contains possible modifier operator types.
  
   Used during attribute calculation. Must be ordered in this way to preserve
   operator precedence.
   */
  case pre_assign = 1
  case pre_mul = 2
  case pre_div = 3
  case mod_add = 4
  case mod_sub = 5
  case post_mul = 6
  case post_mul_immune = 7  // Eos-specific, immune to penalization
  case post_div = 8
  case post_percent = 9
  case post_assign = 10

  init?(rawValue: Int) {
    switch rawValue {
    case -1: self = .pre_assign
    case 0: self = .pre_mul
    case 1: self = .pre_div
    case 2: self = .mod_add
    case 3: self = .mod_sub
    case 4: self = .post_mul
    case 5: self = .post_div
    case 6: self = .post_percent
    case 7: self = .post_assign
    default: return nil
    }
  }
}

extension ModOperator {
  func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
}

enum ModAggregateMode: Int, CaseIterable {

  /*
   Contains possible modifier aggregate modes.
   Used during attribute calculation.
  */
  case stack = 1
  case minimum = 2
  case maximum = 3
}

enum Restriction: Int {

  /*
    Contains possible restriction types.
  
    Used for fit validation.
  */
  case cpu = 1
  case powergrid = 2
  case calibration = 3
  case dronebay_volume = 4
  case drone_bandwidth = 5
  case launched_drone = 6
  case drone_group = 7
  case high_slot = 8
  case mid_slot = 9
  case low_slot = 10
  case rig_slot = 11
  case rig_size = 12
  case subsystem_slot = 13
  case subsystem_index = 14
  case turret_slot = 15
  case launcher_slot = 16
  case implant_index = 17
  case booster_index = 18
  case ship_type_group = 19
  case capital_item = 20
  case max_group_fitted = 21
  case max_group_online = 22
  case max_group_active = 23
  case skill_requirement = 24
  case item_class = 26
  case state = 27
  case charge_group = 28
  case charge_size = 29
  case charge_volume = 30
  case fighter_squad = 31
  case fighter_squad_support = 32
  case fighter_squad_light = 33
  case fighter_squad_heavy = 34
  case loaded_item = 35
}

enum EosTypeId: Int {

  /*
   Contains Eos-specific item type IDs.
  
  Any values defined here must not overlap with regular item type IDs.
  */
  case current_self = -1
}

enum EosEffectId: Int64 {

  /*Contains Eos-specific effect IDs.
  
  Any values defined here must not overlap with regular effect IDs.
  */
  case char_missile_dmg = -1
  case ancillary_paste_armor_rep_boost = -2
}
