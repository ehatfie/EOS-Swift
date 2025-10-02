//
//  Fit.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//



public class MockFleet {
  
}

protocol DefaultImpl {
  
}

public class DefaultSolarSystem: SolarSystem, DefaultImpl {
  public override init(source: SourceManager? = nil) {
    super.init(source: source)
  }
}

protocol DefaultHaving {
  //static var defaultVal: Self.Type { get }
}

public class Fit: FitMessageBroker<MockSubscriber> {
  public var solarSystem: SolarSystem?
  weak var fleet: MockFleet?
  var shipDescriptor: ItemDescriptor<Ship>
  public var ship: Ship? {
    set {
      if let newValue {
        try? self.shipDescriptor.set1(item: newValue, parent: self)
      }
      
    }
    get {
      return shipDescriptor.item
    }
    
  }// Access point for ship.
  var stance: Stance? // Access point for ship stance, also known as tactical mode.
  public var modules: ModuleRacks!
  var rigs: ItemSet<Rig>! //  Set for rigs.
  var drones: String? // Set for drones.
  var fighters: String? // Set for fighter squads.
  var character: Character? // Access point for character.
  public var skills: TypeUniqueSet<Skill>! // Keyed set for skills.
  var implants: ItemSet<Implant>! // Set for implants.
  var boosters: ItemSet<Booster>! // Set for boosters.
  var subsystems: ItemSet<Subsystem>! // Set for subsystems.
  var effect_beacon: EffectBeacon? // Access point for effect beacons (e.g. wormhole effects).
  var restriction: RestrictionService!
  public var stats: StatService! //  All aggregated stats for fit are accessible via this access
  
  
  var incomingDamageDefault: DamageProfile?
  //  point.
  var defaultIncomingDamage: DamageProfile? {
    set {
      print("++ setting incoming damage default \(newValue)")
      self.incomingDamageDefault = newValue
    }
    get {
      print("++ returning incoming damage default \(self.incomingDamageDefault)")
      return self.incomingDamageDefault
    }
  }
  
  @MainActor
  public init(solarSystem: SolarSystem? = DefaultSolarSystem(source: nil), fleet: MockFleet?) {
    print("++ fit init solarSystem \(solarSystem)")
    self.solarSystem =  solarSystem
    self.fleet = fleet
    self.shipDescriptor = ItemDescriptor()
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
      print("++ use default solarSystem")
      let value = SolarSystem(source: SourceManager())
      self.solarSystem = value
      self.solarSystem?.fit = self
    }
    
    if let solarSystem = self.solarSystem {
      solarSystem.fit = self
    }
    
    if let fleet = self.fleet {
      //fleet.fits.add(self)
    }
    
  }
  
  /// Run fit Validation
  public func validate(skipChecks: [Any]) throws {
    //self.restriction.validate()
    try self.restriction.validate(skipChecks: skipChecks)
  }
  
  func setDefaultIncomingDamage(value: Any) {
    
  }
  
  func setRAHIncomingDamage(value: Any) {
    
  }
  
  public override var fit: Fit? {
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
    let skills = fit!.skills.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let implants = fit!.implants.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let boosters = fit!.boosters.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }

    let subsystems = fit!.subsystems.iterator().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let modules = self.modules.items().iter().map { item -> [any BaseItemMixinProtocol] in
      let children = item.childItemIterator(skipAutoItems: skipAutoitems)?.map { $0 } ?? []
      return [item] + children
    }.flatMap { $0 }
    
    let rigs = fit!.rigs.iterator().map { item -> [any BaseItemMixinProtocol] in
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
      item.unload()
    }
  }
}

extension Fit: ItemContainerBaseProtocol {
  public func handleItemAddition(item: ExpectedType, container: any ItemContainerBaseProtocol) throws {
    
  }
  
  public func subItemIterator(item: ExpectedType) -> AnyIterator<any BaseItemMixinProtocol> {
    return AnyIterator({ nil })
  }
  
  public typealias ExpectedType = Any
  
  public func checkClass(item: (any BaseItemMixinProtocol)?, allowNil: Bool) -> Bool {
    true
  }
  
  public func length() -> Int {
    0
  }
  
  
}
