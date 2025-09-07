//
//  Effect.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

import Foundation

public class Effect: Codable {
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

  let attributeId: Int64
  let categoryID: Int64
  let isOffensive: Bool
  let isAssistance: Bool
  let durationAttributeID: Int64
  let dischargeAttributeID: Int64
  let rangeAttributeID: Int64
  let falloffAttributeID: Int64
  let trackingSpeedAttributeID: Int64
  let fittingUseUsageChanceAttributeID: Int64
  let buildStatus: String  //EffectBuildStatus
  var modifiers: [String]  // Modifier

  init(
    attributeId: Int64,
    categoryID: Int64,
    isOffensive: Bool,
    isAssistance: Bool,
    durationAttributeID: Int64,
    dischargeAttributeID: Int64,
    rangeAttributeID: Int64,
    falloffAttributeID: Int64,
    trackingSpeedAttributeID: Int64,
    fittingUseUsageChanceAttributeID: Int64,
    buildStatus: String,
    modifiers: [String]
  ) {
    self.attributeId = attributeId
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
    return self.categoryID == EffectCategoryId.target.rawValue
  }

  var effectStateMap: [EffectCategoryId: State] = [
    EffectCategoryId.passive: State.offline,
    EffectCategoryId.active: State.active,
    EffectCategoryId.target: State.active,
    EffectCategoryId.online: State.online,
    EffectCategoryId.overload: State.overload,
    EffectCategoryId.system: State.offline,
  ]
  
  /// Returns `State` of effect.
  /// It means if item takes this state or higher, effect activates.
  /// - Returns `State`
  var state: State {
    let effectCategory = EffectCategoryId(rawValue: Int(self.categoryID))!
    
    return self.effectStateMap[effectCategory] ?? .offline
  }

  func localModifiers() -> [String] {
    var mods: [String] = []

    mods = self.modifiers.filter { modifier in
      // modifier.affecteeDomain != ModDomain.target
      return true
    }
    // tuple(mods) ?
    return mods
  }

  func projectedModifiers() -> [String] {
    var mods: [String] = []

    mods = self.modifiers.filter { modifier in
      // modifier.affectee_domain == ModDomain.target
      return true
    }
    // tuple(mods)?
    return mods
  }
  

  // TODO: After model definitions
  func getCharge(item: BaseItemMixin) {
    if let autoChargeTypeId = self.getAutoChargeTypeId(item: item) {
      //item.autocharges.get(self.id)
    } else {
      return item.charge
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
  
  open func getCyclesUntilReload(item: BaseItemMixin) -> Double? {
    return .infinity
  }
  
  open func getReloadTime(item: Any) -> Double? {
  // item.state.subtractingReportingOverflow(1
    return nil
  }
  
  /// Return ID of type which should be used as base for autocharge.
  /// Autocharges are automatically loaded charges which are defined by
  /// effects. If None is returned, it means this effect defines no
  /// autocharge.
  open func getAutoChargeTypeId(item: BaseItemMixin) -> Int64? {
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
  func getDuration(item: BaseItemMixin) -> Double? {
    let timeMS = Effect.safeGetAttributeValue(item: item, attributeID: self.durationAttributeID)
    return timeMS / 1000
  }
  
  func getCapUse(item: BaseItemMixin) -> Double? {
    return Effect.safeGetAttributeValue(item: item, attributeID: self.dischargeAttributeID)
  }
  
  func getOptimalRange(item: BaseItemMixin) -> Double? {
    return Effect.safeGetAttributeValue(item: item, attributeID: self.rangeAttributeID)
  }
  
  func getFalloffRange(item: BaseItemMixin) -> Double? {
    return Effect.safeGetAttributeValue(item: item, attributeID: self.falloffAttributeID)
  }
  
  func getFittingUsageChance(item: BaseItemMixin) -> Double? {
    return Effect.safeGetAttributeValue(item: item, attributeID: self.fittingUseUsageChanceAttributeID)
  }
  
  static func safeGetAttributeValue(item: BaseItemMixin, attributeID: Int64) -> Double {
    return item.attributes[attributeID, default: 0]
  }
  
  func getForcedInactiveTime(item: BaseItemMixin) -> Double {
    let timeMS = item.attributes[self.dischargeAttributeID, default: 0]
    return timeMS / 1000
  }
  
  // TODO
  func getCycleParameters(item: BaseItemMixin, reload: Bool) -> Any? {
    //let cyclesUntilReload = self.getCyclesUntilReload(item: )
    return nil
  }
}

// MARK: - Getters for charge-related entities
extension Effect {

}

struct EffectState {
  let categoryID: Int64
  let stateID: Int64

  var effectCategory: EffectCategoryId {
    return EffectCategoryId(rawValue: Int(categoryID))!
  }

  var effectState: State {
    return State(rawValue: Int(stateID))!
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

     def get_optimal_range(self, item):
         return self.__safe_get_attr_value(item, self.range_attr_id)

     def get_falloff_range(self, item):
         return self.__safe_get_attr_value(item, self.falloff_attr_id)

     def get_tracking_speed(self, item):
         return self.__safe_get_attr_value(
             item, self.tracking_speed_attr_id)

     def get_fitting_usage_chance(self, item):
         return self.__safe_get_attr_value(
             item, self.fitting_usage_chance_attr_id)
 */
