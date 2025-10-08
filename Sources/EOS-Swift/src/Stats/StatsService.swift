//
//  StatsService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//
import Foundation

public protocol StatsServiceProtocol:
  StatServiceRegistersProtocol,
  StatServiceSlotsProtocol,
  StatServiceValuesProtocol
{
  
}

public protocol StatServiceRegistersProtocol {
  var ddRegister: DamageDealerRegister { get set }
  var armorRepRegister: ArmorRepairerRegister { get set }
  var shieldRepRegister: ShieldRepairerRegister { get set }
  var cpu: CPURegister { get set }
  var powerGrid: PowergridRegister { get set }
//  var calibration: CalibrationRegister { get set }
//  var dronebay: DronebayVolumeRegister { get set }
//  var droneBandwidth: DroneBandwidthRegister { get set }
//  var turretSlots: TurretSlotRegister { get set }
//  var launcherSlots: LauncherSlotRegister { get set }
}

public protocol StatServiceSlotsProtocol: MaybeFitHaving {
  var highSlots: SlotStats { get }
  var midSlots: SlotStats { get }
  var lowSlots: SlotStats { get }
  var rigSlots: SlotStats { get }
  var subsystemSlots: SlotStats { get }
  var fighterSquads: SlotStats { get }
  
  func getSlotStats(container: any ItemContainerBaseProtocol, attrId: AttrId) -> SlotStats
}

public protocol StatServiceValuesProtocol: MaybeFitHaving, StatServiceRegistersProtocol {
  var hp: ItemHP { get }
  
  var resists: any TankingLayersProtocol { get }
  var worstCaseEHP: ItemHP { get }
  var agilityFactor: Double? { get }
  var alignTime: Double? { get }
  
  func getEHP(damageProfile: DamageProfile?) -> ItemHP
  func getVolley(itemFilter: Any?, targetResists: ResistProfile?) -> DamageStats
  func getDPS(itemFilter: Any?, reload: Bool, targetResists: ResistProfile?) -> DamageStats
  
  func getArmorRps(damageProfile: DamageProfile, reload: Bool) -> Double
  func getShieldRps(damageProfile: DamageProfile, reload: Bool) -> Double
}

extension StatServiceValuesProtocol {
  
  /// Fetch ship HP stats.
  /// Returns:
  /// TankingLayersTotal helper container instance. If ship data cannot be fetched, HP values will be None.
  public var hp: ItemHP {
    return self.fit?.ship?.hp ?? ItemHP(hull: 0.0, armor: 0.0, shield: 0.0)
  }
  /// Fetch ship resistances.
  /// Returns:
  /// TankingLayers helper container instance, whose attributes are
  /// DmgTypes helper container instances. If ship data cannot be fetched, resistance values will be None.
  public var resists: any TankingLayersProtocol {
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
  public func getEHP(damageProfile: DamageProfile? = nil) -> ItemHP {
    print("^^ getEHP fit: \(self.fit) ship: \(self.fit?.ship)")
    return self.fit?.ship?.getEHP(damageProfile: damageProfile) ?? ItemHP(hull: 0, armor: 0, shield: 0)
  }
  
  public var worstCaseEHP: ItemHP {
    self.fit?.ship?.worstCaseEHP ?? ItemHP(hull: 0, armor: 0, shield: 0)
  }
  
  public func getVolley(itemFilter: Any? = nil, targetResists: ResistProfile? = nil) -> DamageStats {
    //return DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
    return self.ddRegister.getVolley(itemFilter: itemFilter, targetResists: targetResists)
  }
  
  public func getDPS(itemFilter: Any? = nil, reload: Bool = false, targetResists: ResistProfile? = nil) -> DamageStats {
    //DamageStats(em: 0, thermal: 0, kinetic: 0, explosive: 0)!
    
    return self.ddRegister.getDps(itemFilter: itemFilter, reload: reload, targetResists: targetResists)
  }
  
  public func getArmorRps(damageProfile: DamageProfile, reload: Bool = false) -> Double {

    if damageProfile is DefaultImpl {
      let dmgProfile = self.fit?.defaultIncomingDamage
      //return 0.0
      return self.armorRepRegister.getRps(item: self.fit?.ship, damageProfile: dmgProfile, reload: reload)
    }
    //return 0.0
    return self.armorRepRegister.getRps(item: self.fit?.ship, damageProfile: damageProfile, reload: reload)
  }
  
  public func getShieldRps(damageProfile: DamageProfile, reload: Bool) -> Double {
    if damageProfile is DefaultImpl {
      let dmgProfile = self.fit?.defaultIncomingDamage
      return 0.0
      //return self.shieldRepRegister.getRps(item: self.fit?.ship, damageProfile: dmgProfile, reload: reload)
    }
    //return 0.0
    return self.shieldRepRegister.getRps(item: self.fit?.ship, damageProfile: damageProfile, reload: reload)
  }
  
  public var agilityFactor: Double? {
    guard let ship = self.fit?.ship else {
      return nil
    }
    guard let agility = ship.attributes![.agility],
          let mass = ship.attributes![.mass] else {
      return nil
    }
    
    let agilityFactor = -log(0.25) * agility * mass / 1000000
    return agilityFactor
  }
  
  public var alignTime: Double? {
    guard let agilityFactor else {
      return nil
    }
    return ceil(agilityFactor)
  }
}

extension StatServiceValuesProtocol {
  public var highSlots: SlotStats {
    guard let modules = fit?.modules.high else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .hi_slots)
  }
  
  public var midSlots: SlotStats {
    guard let modules = fit?.modules.mid else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .med_slots)
  }
  
  public var lowSlots: SlotStats {
    guard let modules = fit?.modules.low else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .low_slots)
  }
  
  public var rigSlots: SlotStats {
    guard let modules = fit?.rigs else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .rig_slots)
  }
  
  public var subsystemSlots: SlotStats {
    guard let modules = fit?.subsystems else {
      return SlotStats(used: 0, total: 0)
    }
    
    return self.getSlotStats(container: modules, attrId: .subsystem_slot)
  }
  
  public var fighterSquads: SlotStats {
    return SlotStats(used: 0, total: 0)
//    guard let modules = fit?.fighters else {
//      return SlotStats(used: 0, total: 0)
//    }
    
    ///return self.getSlotStats(container: modules, attrId: .low_slots)
  }
  
  
  public func getSlotStats(container: any ItemContainerBaseProtocol, attrId: AttrId) -> SlotStats {
    let used = container.length()
    let total = Int(self.fit?.ship?.attributes![attrId] ?? 0)
    return SlotStats(used: used, total: total)
  }
}

public class StatService: StatsServiceProtocol {
  weak public var fit: Fit? = nil
  
  public var ddRegister: DamageDealerRegister
  public var armorRepRegister: ArmorRepairerRegister
  public var shieldRepRegister: ShieldRepairerRegister
  public var cpu: CPURegister
  public var powerGrid: PowergridRegister
  public var calibration: CalibrationRegister
  public var dronebay: DronebayVolumeRegister
  public var droneBandwidth: DroneBandwidthRegister
  public var turretSlots: TurretSlotRegister
  public var launcherSlots: LauncherSlotRegister
  
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
