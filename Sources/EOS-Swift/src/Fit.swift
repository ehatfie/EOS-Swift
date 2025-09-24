//
//  Fit.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//



class MockFleet {
  
}

protocol DefaultImpl {
  
}

class DefaultSolarSystem: SolarSystem, DefaultImpl {
  
}

protocol DefaultHaving {
  //static var defaultVal: Self.Type { get }
}

class Fit: FitMessageBroker<MockSubscriber> {
  
  weak var solarSystem: SolarSystem?
  weak var fleet: MockFleet?
  var ship: Ship? // Access point for ship.
  var stance: Stance? // Access point for ship stance, also known as tactical mode.
  var modules: ModuleRacks!
  //var modules.high: // List for high-slot modules.
  //var modules.mid: // List for medium-slot modules.
  //var modules.low: // List for low-slot modules.
  var rigs: ItemSet<Rig>! //  Set for rigs.
  var drones: String? // Set for drones.
  var fighters: String? // Set for fighter squads.
  var character: Character? // Access point for character.
  var skills: TypeUniqueSet<Skill>! // Keyed set for skills.
  var implants: ItemSet<Implant>! // Set for implants.
  var boosters: ItemSet<Booster>! // Set for boosters.
  var subsystems: ItemSet<Subsystem>! // Set for subsystems.
  var effect_beacon: EffectBeacon? // Access point for effect beacons (e.g. wormhole effects).
  var restriction: RestrictionService!
  var stats: StatService! //  All aggregated stats for fit are accessible via this access
  //var restriction: RestrictionService?
  //  point.
  var defaultIncomingDamage: DamageProfile? {
    set {
      return
    }
    get {
      nil
    }
  }
  
  init(solarSystem: SolarSystem? = DefaultSolarSystem(source: nil), fleet: MockFleet?) {
    self.solarSystem =  solarSystem
    self.fleet = fleet
  
    super.init()
    

    self.skills = TypeUniqueSet(parent: self) //<Skill>(parent: self, containerOverride: nil)
    self.implants = ItemSet<Implant>(parent: self, containerOverride: nil)
    self.boosters = ItemSet<Booster>(parent: self, containerOverride: nil)
    
    // Ship related containers
    self.subsystems = ItemSet<Subsystem>(parent: self, containerOverride: nil)
    self.modules = ModuleRacks(
      high: ItemList(parent: self),
      mid: ItemList(parent: self),
      low: ItemList(parent: self)
    )
    self.rigs = ItemSet<Rig>(parent: self, containerOverride: nil)
    // self.drones = ItemSet<Drone>(parent: self, containerOverride: nil)
    // self.fighters = ItemSet<FighterSquad>(parent: self, containerOverride: nil)
    
    // Initialize services
    self.restriction = RestrictionService(fit: self)
    self.stats = StatService(fit: self)
    
    // Initialize simulators
    // TODO
    // self.rahSim = ReactiveArmorHardenerSimulator(parent: self)
    
    // Initialize defaults
    self.defaultIncomingDamage = DamageProfile(25, thermal: 25, kinetic: 25, explosive: 25)
    // As character object shouldn't change in any sane cases, initialize it
    // here. It has to be assigned after fit starts to track list of items
    // to make sure it's part of it
    self.character = Character(typeID: TypeId.characterStatic.rawValue)
    
    // Add fit to solar syhstem
    if solarSystem is DefaultImpl {
      
    }
    
    if let solarSystem = self.solarSystem {
      solarSystem.fit = self
    }
    
    if let fleet = self.fleet {
      //fleet.fits.add(self)
    }
    
  }
  
  /// Run fit Validation
  func validate(skipChecks: [Any]) throws {
    //self.restriction.validate()
    try self.restriction.validate(skipChecks: skipChecks)
  }
  
  func setDefaultIncomingDamage(value: Any) {
    
  }
  
  func setRAHIncomingDamage(value: Any) {
    
  }
  
  override var fit: Fit {
    return self
  }
  
  /*
   def _item_iter(self, skip_autoitems=False):
       single = (self.character, self.ship, self.stance, self.effect_beacon)
       for item in chain(
           (i for i in single if i is not None),
           self.skills,
           self.implants,
           self.boosters,
           self.subsystems,
           self.modules.items(),
           self.rigs,
           self.drones,
           self.fighters
       ):
           yield item
           for child_item in item._child_item_iter(
               skip_autoitems=skip_autoitems
           ):
               yield child_item
   */
  func itemIterator(skipAutoitems: Bool = false) -> AnyIterator<any BaseItemMixinProtocol> {
    let optionalValues: [(any BaseItemMixinProtocol)?] = [
      self.character, self.ship, self.stance, self.effect_beacon
    ]

    // TODO: Simplify
    let skills = fit.skills.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let implants = fit.implants.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let boosters = fit.boosters.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }

    let subsystems = fit.subsystems.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let modules = self.modules.items().iter().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let rigs = fit.rigs.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }

    let values: [any BaseItemMixinProtocol] = optionalValues.compactMap { $0 } + skills + implants + boosters + subsystems + modules + rigs //TODO: + drones + fighters
    
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func loadedItemIterator(skipAutoItems: Bool = false) -> AnyIterator<any BaseItemMixinProtocol> {
    /*
     def _loaded_item_iter(self, skip_autoitems=False):
         for item in self._item_iter(skip_autoitems=skip_autoitems):
             if item._is_loaded:
                 yield item

     */
    let values: [any BaseItemMixinProtocol] = self.itemIterator(skipAutoitems: skipAutoItems).filter { $0.isLoaded }
    
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func loadItems() {
    for item in self.itemIterator(skipAutoitems: true) {
      item.load()
    }
  }
  
  func unloadItems() {
    for item in self.itemIterator(skipAutoitems: true) {
      item.load()
    }
  }
}
