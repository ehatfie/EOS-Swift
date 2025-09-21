//
//  StatsService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

protocol StatServiceRegistersProtocol {
  var ddRegister: DamageDealerRegister { get set }
  var armorRepRegister: ArmorRepairerRegister { get set }
  var shieldRepRegister: ShieldRepairerRegister { get set }
  var cpu: CPURegister { get set }
  var powerGrid: PowergridRegister { get set }
  var calibration: CalibrationRegister { get set }
  var dronebay: DronebayVolumeRegister { get set }
  var droneBandwidth: DroneBandwidthRegister { get set }
  var turretSlots: TurretSlotRegister { get set }
  var launcherSlots: LauncherSlotRegister { get set }
}

protocol StatServiceRegisterSlotsProtocol: MaybeFitHaving {
  var highSlots: SlotStats { get }
  var midSlots: SlotStats { get }
  var lowSlots: SlotStats { get }
  var rigSlots: SlotStats { get }
  var subsystemSlots: SlotStats { get }
  var fighterSquads: SlotStats { get }
  
  func getSlotStats(container: any ItemContainerBaseProtocol) -> SlotStats
}

protocol StatServiceRegisterValuesProtocol: MaybeFitHaving, StatServiceRegistersProtocol {
  var hp: ItemHP { get }
  
  var resists: any TankingLayersProtocol { get }
  var worstCaseEHP: ItemHP { get }
  var agilityFactor: Double { get }
  var alignTime: Double { get }
  
  func getEHP(damageProfile: DamageProfile?) -> ItemHP
  func getVolley(itemFilter: Any?, targetResists: ResistProfile?) -> DamageStats
  func getDPS(itemFilter: Any?, targetResists: ResistProfile?) -> DamageStats
  
  func getArmorRps(damageProfile: DamageProfile, reload: Bool) -> Double
  func getShieldRps(damageProfile: DamageProfile, reload: Bool) -> Double
}

extension StatServiceRegisterValuesProtocol {
  
  /// Fetch ship HP stats.
  /// Returns:
  /// TankingLayersTotal helper container instance. If ship data cannot be fetched, HP values will be None.
  var hp: ItemHP {
    return self.fit?.ship?.hp ?? ItemHP(hull: 0.0, armor: 0.0, shield: 0.0)
  }
  /// Fetch ship resistances.
  /// Returns:
  /// TankingLayers helper container instance, whose attributes are
  /// DmgTypes helper container instances. If ship data cannot be fetched, resistance values will be None.
  var resists: any TankingLayersProtocol {
    let empty = ResistProfile(0.0, thermal: 0.0, kinetic: 0.0, explosive: 0.0)!
    return self.fit?.ship?.resists ?? TankingLayers<ResistProfile>(hull: empty, armor: empty, shield: empty)
  }
  
  /*
   Get effective HP of an item against passed damage profile.

   Args:
       dmg_profile (optional): DmgProfile helper container instance. If
           not specified, default on-fit damage profile is used.

   Returns:
       TankingLayersTotal helper container instance. If ship data cannot be
       fetched, EHP values will be None.
   */
  func getEHP(damageProfile: DamageProfile? = nil) -> ItemHP {
    return self.fit?.ship?.getEHP(damageProfile: damageProfile) ?? ItemHP(hull: 0, armor: 0, shield: 0)
  }
  
  var worstCaseEHP: ItemHP {
    self.fit?.ship?.worstCaseEHP ?? ItemHP(hull: 0, armor: 0, shield: 0)
  }
  
  func getVolley(itemFilter: Any? = nil, targetResists: ResistProfile? = nil) -> DamageStats {
    return self.ddRegister.getVolley(itemFilter: itemFilter, targetResists: targetResists)
  }
  
  func getDPS(itemFilter: Any? = nil, reload: Bool = false, targetResists: ResistProfile? = nil) -> DamageStats {
    return self.ddRegister.getDps(itemFilter: itemFilter, reload: reload, targetResists: targetResists)
  }
}

extension StatServiceRegisterValuesProtocol {
  var highSlots: SlotStats {
    guard let modules = fit?.modules.high else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .hi_slots)
  }
  
  var midSlots: SlotStats {
    guard let modules = fit?.modules.mid else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .med_slots)
  }
  
  var lowSlots: SlotStats {
    guard let modules = fit?.modules.low else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .low_slots)
  }
  
  var rigSlots: SlotStats {
    guard let modules = fit?.rigs else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .rig_slots)
  }
  
  var subSystemSlots: SlotStats {
    guard let modules = fit?.subsystems else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .subsystem_slot)
  }
  
  var fighterSquads: SlotStats {
    return SlotStats(used: 0, total: 0)
//    guard let modules = fit?.fighters else {
//      return SlotStats(used: 0, total: 0)
//    }
    
    ///return self.getSlotStats(container: modules, attrId: .low_slots)
  }
  
  
  func getSlotStats(container: any ItemContainerBaseProtocol, attrId: AttrId) -> SlotStats {
    let used = container.length()
    let total = Int(self.fit?.ship?.attributes[attrId] ?? 0)
    return SlotStats(used: used, total: total)
  }
}

class StatService: StatServiceRegistersProtocol {
  weak var fit: Fit? = nil
  
  var ddRegister: DamageDealerRegister
  var armorRepRegister: ArmorRepairerRegister
  var shieldRepRegister: ShieldRepairerRegister
  var cpu: CPURegister
  var powerGrid: PowergridRegister
  var calibration: CalibrationRegister
  var dronebay: DronebayVolumeRegister
  var droneBandwidth: DroneBandwidthRegister
  var turretSlots: TurretSlotRegister
  var launcherSlots: LauncherSlotRegister
  
  // var launchedDrones: LaunchedDroneRegister
  // var fighterSquadsSupport: FighterSquadSupportRegister
  // var figherSquadsLight: FighterSquadLightRegister
  // var fighterSquadsHeavy: FighterSquadHeavyRegister
  
  init(fit: Fit) {
    self.fit = fit
    
    self.ddRegister = DamageDealerRegister(fit: fit)
    self.armorRepRegister = ArmorRepairerRegister(fit: fit)
    self.shieldRepRegister = ShieldRepairerRegister(fit: fit)
    self.cpu = CPURegister(fit: fit)
    self.powerGrid = PowergridRegister(fit: fit)
    self.calibration = CalibrationRegister(fit: fit)
    self.dronebay = DronebayVolumeRegister(fit: fit)
    self.droneBandwidth = DroneBandwidthRegister(fit: fit)
    self.turretSlots = TurretSlotRegister(fit: fit)
    self.launcherSlots = LauncherSlotRegister(fit: fit)
    
  }
}
