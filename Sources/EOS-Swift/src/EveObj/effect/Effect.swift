//
//  Effect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

import Foundation

public class Effect: Hashable {
  public static func == (lhs: Effect, rhs: Effect) -> Bool {
    return lhs.effectId == rhs.effectId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  /*
   Represents single eve effect.
  
      Effects are the building blocks which describe what items do with other
      items.
  
      Attributes:
          id: Identifier of the effect.
          category_id: Defines effect category, which influences when and how
              effect is applied - always, when item is active, overloaded, etc.
          is_offensive: Whether effect is offensive (e.g. guns).
          is_assistance: Whether the effect is assistance (e.g. remote repairers).
          duration_attr_id: Value of attribute with this ID on item defines effect
              cycle time.
          discharge_attr_id: Value of attribute with this ID on item defines how
              much cap does this effect take per cycle.
          range_attr_id: Value of attribute with this ID on item defines max range
              where effect is applied to its full potency.
          falloff_attr_id: Value of attribute with this ID on item defines
              additional range where effect is still applied, but with diminished
              potency.
          tracking_speed_attr_id: Value of attribute with this ID on item defines
              tracking speed which reduces effect efficiency vs targets which are
              small and have decent angular velocity.
          fitting_usage_chance_attr_id: Value of attribute with this ID on item
              defines chance of this effect being applied when item is added to
              fit, e.g. booster side-effects.
          resist_attr_id: Value of attribute with this ID on affectee item defines
              how it can resist this effect.
          build_status: Effect-to-modifier build status.
          modifiers: Iterable with modifiers. It's actually not effect which
              describes modifications this item does, but these child objects.
              Each modifier instance must belong to only one effect, otherwise
              attribute calculation may be improper in several edge cases.
      */

  let effectId: Int64
  let categoryID: EffectCategoryId?
  let isOffensive: Bool
  let isAssistance: Bool
  let durationAttributeID: Int64?
  let dischargeAttributeID: Int64?
  let rangeAttributeID: Int64?
  let falloffAttributeID: Int64?
  let trackingSpeedAttributeID: Int64?
  let fittingUseUsageChanceAttributeID: Int64?
  let buildStatus: EffectBuildStatus?  //EffectBuildStatus
  var modifiers: [any BaseModifierProtocol]  // Modifier

  init(
    effectId: Int64,
    categoryID: EffectCategoryId? = nil,
    isOffensive: Bool = false,
    isAssistance: Bool = false,
    durationAttributeID: Int64? = nil,
    dischargeAttributeID: Int64? = nil,
    rangeAttributeID: Int64? = nil,
    falloffAttributeID: Int64? = nil,
    trackingSpeedAttributeID: Int64? = nil,
    fittingUseUsageChanceAttributeID: Int64? = nil,
    resistanceAttributeId: Int64? = nil,
    buildStatus: EffectBuildStatus? = nil,
    modifiers: [any BaseModifierProtocol] = []
  ) {
    self.effectId = effectId
    self.categoryID = categoryID
    self.isOffensive = isOffensive
    self.isAssistance = isAssistance
    self.durationAttributeID = durationAttributeID
    self.dischargeAttributeID = dischargeAttributeID
    self.rangeAttributeID = rangeAttributeID
    self.falloffAttributeID = falloffAttributeID
    self.trackingSpeedAttributeID = trackingSpeedAttributeID
    self.fittingUseUsageChanceAttributeID = fittingUseUsageChanceAttributeID
    self.buildStatus = buildStatus
    self.modifiers = modifiers
  }

  var isProjectable: Bool {
    return self.categoryID == EffectCategoryId.target
  }

  var effectStateMap: [EffectCategoryId: StateI] = [
    EffectCategoryId.passive: StateI.offline,
    EffectCategoryId.active: StateI.active,
    EffectCategoryId.target: StateI.active,
    EffectCategoryId.online: StateI.online,
    EffectCategoryId.overload: StateI.overload,
    EffectCategoryId.system: StateI.offline,
  ]
  
  /// Returns `State` of effect.
  /// It means if item takes this state or higher, effect activates.
  /// - Returns `State`
  var state: StateI {
    guard let effectCategory = self.categoryID else {
      return .offline
    }
    
    return self.effectStateMap[effectCategory] ?? .offline
  }

  func localModifiers() -> [any BaseModifierProtocol] {
    var mods: [any BaseModifierProtocol] = []

    mods = self.modifiers.filter { modifier in
      return modifier.affecteeDomain != .target
    }
    // tuple(mods) ?
    return mods
  }

  func projectedModifiers() -> [any BaseModifierProtocol] {
    var mods: [any BaseModifierProtocol] = []

    mods = self.modifiers.filter { modifier in
      // modifier.affectee_domain == ModDomain.target
      return true
    }
    // tuple(mods)?
    return mods
  }
  

  // TODO: After model definitions
  func getCharge(item: any BaseItemMixinProtocol) {
    if let autoChargeTypeId = self.getAutoChargeTypeId(item: item) {
      //item.autocharges.get(self.id)
    } else {
      // check if item has Module?
      //return item.charge
    }
    /*
     # Getters for charge-related entities
     def get_charge(self, item):
         """Get charge which should be used by this effect."""
         if self.get_autocharge_type_id(item) is not None:
             return item.autocharges.get(self.id)
         try:
             return item.charge
         except AttributeError:
             return None
     */
  }
  
  func getCyclesUntilReload(item: any BaseItemMixinProtocol) -> Double? {
    return .infinity
  }
  

  
 func getReloadTime(item: any BaseItemMixinProtocol) -> Double? {
   print("TODO getReloadTime")
  // item.state.subtractingReportingOverflow(1
    return nil
  }
  
  /// Return ID of type which should be used as base for autocharge.
  /// Autocharges are automatically loaded charges which are defined by
  /// effects. If None is returned, it means this effect defines no
  /// autocharge.
  func getAutoChargeTypeId(item: any BaseItemMixinProtocol) -> Int64? {
    return nil
  }
  /*
   def get_autocharge_type_id(self, item):
       """Return ID of type which should be used as base for autocharge.

       Autocharges are automatically loaded charges which are defined by
       effects. If None is returned, it means this effect defines no
       autocharge.
       """
       return None
   */
}

extension Effect {
  func getDuration(item: any BaseItemMixinProtocol) -> Double {
    guard let durationAttributeID else {
      return 0.0
    }
    let timeMS = Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: durationAttributeID)!)
    return timeMS / 1000
  }
  
  func getCapUse(item: any BaseItemMixinProtocol) -> Double? {
    guard let dischargeAttributeID else {
      return nil
    }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: dischargeAttributeID)!)
  }
  
  func getOptimalRange(item: any BaseItemMixinProtocol) -> Double? {
    guard let rangeAttributeID else {
      return nil
    }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: rangeAttributeID)!)
  }
  
  func getFalloffRange(item: any BaseItemMixinProtocol) -> Double? {
    guard let falloffAttributeID else {
      return nil
    }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: falloffAttributeID)!)
  }
  
  func getFittingUsageChance(item: any BaseItemMixinProtocol) -> Double? {
    guard let fittingUseUsageChanceAttributeID else { return nil }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: fittingUseUsageChanceAttributeID)!)
  }
  
  static func safeGetAttributeValue(item: any BaseItemMixinProtocol, attributeID: AttrId) -> Double {
    return item.attributes![attributeID, default: 0]
  }
  
  func getForcedInactiveTime(item: any BaseItemMixinProtocol) -> Double {
    guard let dischargeAttributeID else {
      return 0.0
    }
    let timeMS = item.attributes![AttrId(rawValue: dischargeAttributeID)!, default: 0]
    return timeMS / 1000
  }
  
  // TODO
  func getCycleParameters(item: any BaseItemMixinProtocol, reload: Bool) -> Any? {
    //let cyclesUntilReload = self.getCyclesUntilReload(item: )
    let cyclesUntilReload = self.getCyclesUntilReload(item: item) ?? 0
    guard cyclesUntilReload > 0 else { return nil }
    let activeTime = self.getDuration(item: item)
    let forcedInactiveTime = getForcedInactiveTime(item: item)
    let reloadTime = self.getReloadTime(item: item)
    if reloadTime == nil && cyclesUntilReload < .infinity {
      let finalCycles: Double = 1
      
      let earlyCycles = cyclesUntilReload - finalCycles
      if earlyCycles == 0 {
        return CycleInfo(activeTime: activeTime, inactiveTime: 0, quantity: 1)
      }
      
      if forcedInactiveTime == 0 {
        return CycleInfo(activeTime: activeTime, inactiveTime: 0, quantity: cyclesUntilReload)
      }
      
      return CycleSequence(sequence: [
        CycleInfo(activeTime: activeTime, inactiveTime: forcedInactiveTime, quantity: earlyCycles),
        CycleInfo(activeTime: activeTime, inactiveTime: 0, quantity: finalCycles)
        ], quantity: finalCycles
      )
    }
      /*
       return CycleSequence((
       CycleInfo(active_time, forced_inactive_time, early_cycles),
       CycleInfo(active_time, 0, final_cycles)
       ), 1)
       */
      /*
       # Module cycles the same way all the time in 3 cases:
       # 1) caller doesn't want to take into account reload time
       # 2) effect does not have to reload anything to keep running
       # 3) effect has enough time to reload during inactivity periods
       if (
       not reload or
       cycles_until_reload == math.inf or
       forced_inactive_time >= reload_time
       ):
       return CycleInfo(active_time, forced_inactive_time, math.inf)
       */
      if !reload || cyclesUntilReload == .infinity {
        // return CycleInfo(active_time, forced_inactive_time, math.inf)
      } else if let reloadTime = reloadTime, forcedInactiveTime >=  reloadTime {
        // return CycleInfo(active_time, forced_inactive_time, math.inf)
      } else {
        let finalCycles: Double = 1.0
        let earlyCycles = cyclesUntilReload - finalCycles
        if earlyCycles == 0 {
          // return CycleInfo(active_time, reload_time, math.inf)
        } else {
          /*
           return CycleSequence((
               CycleInfo(active_time, forced_inactive_time, early_cycles),
               CycleInfo(active_time, reload_time, final_cycles)
           ), math.inf)
           */
        }
      }
    
    return nil
  }
  
  func getTrackingSpeed(item: any BaseItemMixinProtocol) -> Double? {
    //         return self.__safe_get_attr_value(
    // item, self.tracking_speed_attr_id)
    guard let trackingSpeedAttributeID else {
      return nil
    }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: trackingSpeedAttributeID)!)
  }

  func getCapUse(item: any BaseItemMixinProtocol) -> Double {
    guard let dischargeAttributeID else {
      return 0.0
    }
    return Effect.safeGetAttributeValue(item: item, attributeID: AttrId(rawValue: dischargeAttributeID)!)
  }
}

// MARK: - Getters for charge-related entities
extension Effect {

}

struct EffectState {
  let categoryID: Int64
  let stateID: Int64

  var effectCategory: EffectCategoryId {
    return EffectCategoryId(rawValue: Int64(Int(categoryID)))!
  }

  var effectState: StateI {
    return StateI(rawValue: Int(stateID))!
  }
}


/*
 
 

     def get_autocharge_type_id(self, item):
         """Return ID of type which should be used as base for autocharge.

         Autocharges are automatically loaded charges which are defined by
         effects. If None is returned, it means this effect defines no
         autocharge.
         """
         return None

     def get_cycles_until_reload(self, item):
         """Get how many cycles effect can run until it has to be reloaded.

         If effect cannot be cycled, returns None.
         """
         return math.inf

     def get_reload_time(self, item):
         """Get effect reload time in seconds.

         If effect cannot be reloaded, returns None.
         """
         try:
             return item.reload_time
         except AttributeError:
             return None

     # Getters for effect-referenced attributes
     def get_duration(self, item):
         time_ms = self.__safe_get_attr_value(item, self.duration_attr_id)
         # Time is specified in milliseconds, but we want to return seconds
         try:
             return time_ms / 1000
         except TypeError:
             return time_ms

     def get_cap_use(self, item):
         return self.__safe_get_attr_value(item, self.discharge_attr_id)

     def get_fitting_usage_chance(self, item):
         return self.__safe_get_attr_value(
             item, self.fitting_usage_chance_attr_id)
 */
