//
//  AffectionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//
struct AffecteeInfo: Hashable {
  static func == (lhs: AffecteeInfo, rhs: AffecteeInfo) -> Bool {
    return lhs.effect == rhs.effect
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(item))
    hasher.combine(ObjectIdentifier(effect))
  }
  
  let item: any BaseItemMixinProtocol
  let effect: BaseRepairEffect
}

struct AffecteeDomain: Hashable {
  static func == (lhs: AffecteeDomain, rhs: AffecteeDomain) -> Bool {
    return lhs.effect == rhs.effect
  }
  
  func hash(into hasher: inout Hasher) {
    if let fit = fit {
      hasher.combine(ObjectIdentifier(fit))
    }
    hasher.combine(ObjectIdentifier(effect))
  }
  
  let fit: Fit?
  let effect: BaseRepairEffect
}


/*
 struct RepairerData: Hashable {
   static func == (lhs: RepairerData, rhs: RepairerData) -> Bool {
     return lhs.effect == rhs.effect
   }
   
   func hash(into hasher: inout Hasher) {
     hasher.combine(self)
   }
   
   let item: any BaseItemMixinProtocol
   let effect: BaseRepairEffect
 }
 */

struct AffectorSpec: Hashable {
  public var modifier: any BaseModifierProtocol
  public var effect: Effect
  public var itemType: any BaseItemMixinProtocol
  
  //'item', 'effect', 'modifier'
  
  static func == (lhs: AffectorSpec, rhs: AffectorSpec) -> Bool {
    return lhs.modifier.affecteeDomain == rhs.modifier.affecteeDomain
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(modifier))
    hasher.combine(ObjectIdentifier(itemType))
  }
}

struct AffectorModifier: Hashable {
  let affecteeFilter: ModAffecteeFilter
  let modDomain: ModDomain
  let affecteeFilterExtraArg: Int64
  let affecteeDomain: ModDomain
  let affecteeAtributeId: AttrId
}

class AffectionRegister {
  var affectees: Set<BaseItemMixin> = []
  var affecteesDomain = KeyedStorage()
  var affecteesDomainGroup = KeyedStorage()
  var affecteesDomainSkillRequirement = KeyedStorage()
  var affecteesOwnerSkillRequirement = KeyedStorage()
  var affectorsItemOther = KeyedStorage()
  var affectorsItemAwaiting = KeyedStorage()
  var affectorsItemActive = KeyedStorage()
  var affectorsDomain = KeyedStorage()
  var affectorsDomainGroup = KeyedStorage()
  var affectorsDomainSkillRequirement = KeyedStorage()
  var affectorsOwnerSkillRequirement = KeyedStorage()
  
  init() {
    
  }
  
  /// Get iterable with items influenced by passed local affector spec.
  func getLocalAffecteeItems(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol]? {
    var affecteeFilter = affectorSpec.modifier.affecteeFilter
    // Direct item modification needs to use local-specific getters
    
    if affecteeFilter == .item {
      let affecteeDomain = affectorSpec.modifier.affecteeDomain
      switch affecteeDomain {
      case .me: return self.getLocalAffecteesSelf(affectorSpec: affectorSpec)
      case .character: return self.getLocalAffecteesCharacter(affectorSpec: affectorSpec)
      case .ship: return self.getLocalAffecteesShip(affectorSpec: affectorSpec)
      case .other: return self.getLocalAffecteesOther(affectorSpec: affectorSpec)
      default: return nil
      }
    } else {
      // En-masse filtered modification can use shared affectee item getters
      // affectee_domain = self.__resolve_local_domain(affector_spec)
      guard let affecteeDomain = resolveLocalDomain(affectorSpec: affectorSpec) else {
        print("++ no affectee Domain")
        return nil
      }
      // affectee_fits = affector_spec.item._fit,
      guard let affecteeFits = affectorSpec.itemType.fit else {
        print("++ no affectee fit")
        return nil
      }
      switch affecteeFilter {
      case .domain:
        let value = self.getAffecteesDomain(affecteeDomain: affecteeDomain, affecteeFits: [affecteeFits])
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .domain_group:
        let value = self.getAffecteesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: [affecteeFits])
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .domain_skillrq:
        let value = self.getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: [affecteeFits])
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .owner_skillrq:
        let value = self.getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: [affecteeFits])
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      default: return nil
      }
    }
    
  }

  
  /// Get iterable with items influenced by projected affector spec.
  func getProjectedAffecteeItems(affectorSpec: AffectorSpec, targetItems: [BaseItemMixin]) -> [any BaseItemMixinProtocol]? {
    var affecteeFilter = affectorSpec.modifier.affecteeFilter
    // Return targeted items when modification affects just them directly
    if affecteeFilter == .item {
      // return {i for i in tgt_items if i in self.__affectees}
      return targetItems.filter({ self.affectees.contains($0) })
    } else {
      // En-masse modifications of items located on targeted items use shared affectee item getters
      let affecteeFits = targetItems.filter { $0 is Ship }.compactMap { $0.fit }
      switch affecteeFilter {
      case .domain:
        let value = self.getAffecteesDomain(affecteeDomain: .ship, affecteeFits: affecteeFits)
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .domain_group:
        let value = self.getAffecteesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: .ship, affecteeFits: affecteeFits)
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .domain_skillrq:
        let value = self.getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: .ship, affecteeFits: affecteeFits)
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      case .owner_skillrq:
        let value = self.getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: .ship, affecteeFits: affecteeFits)
        return Array(value).compactMap { $0 as? any BaseItemMixinProtocol }
      default: return nil
      }
    }
  }
  
  func getAffectorSpecs(affecteeItem: any BaseItemMixinProtocol) -> Set<AnyHashable>? {
    let affecteeFit = affecteeItem.fit
    var affectorSpecs = Set<AnyHashable>()
    var affectorStorage = self.affectorsItemActive
    var key: AnyHashable = affecteeItem as! AnyHashable
    
    let value = affectorStorage.dictionary[key, default: Set<AnyHashable>()]
    affectorSpecs.insert(value)
    guard let affecteeDomain = affecteeItem.modifierDomain else {
      return nil
    }
    // Domain
    affectorStorage = self.affectorsDomainGroup
    let foo = (affecteeFit, affecteeDomain)
    key = foo as! AnyHashable
    let default1 = Set<AnyHashable>()
    affectorSpecs.insert(affectorStorage.dictionary[key, default: default1])
    
    // Domain and group
    affectorStorage = self.affectorsDomainGroup
    key = (affecteeFit, affecteeDomain, affecteeItem.itemType?.groupId) as! AnyHashable
    affectorSpecs.insert(affectorStorage.dictionary[key, default: default1])
    
    // Domain and skill requirement
    affectorStorage = self.affectorsDomainSkillRequirement
    guard let requiredSkills = affecteeItem.itemType?.requiredSkills else {
      print("++ no itemType")
      return nil
    }
    
    for affecteeStorageRequirementTypeId in requiredSkills {
      key = (affecteeFit, affecteeDomain, affecteeStorageRequirementTypeId) as! AnyHashable
      affectorSpecs.insert(affectorStorage.dictionary[key, default: default1])
    }
    
    return affectorSpecs
  }
  
  /// Add passed affectee item to the register.
  /// We track affectee items to efficiently update attributes when set of items influencing them changes.
  func registerAffecteeItem(affecteeItem: BaseItemMixin) {
   // self.affectees.insert(AffecteeInfo)
    self.affectees.insert(affecteeItem)
    guard let affecteeFit = affecteeItem.fit else {
      return
    }
    for (key, storage) in getAffecteeStorages(affecteeFit: affecteeFit, affecteeItem: affecteeItem) {
      storage.addDataEntry(key: key, data: affecteeItem)
    }
    
     // Process special affector specs separately. E.g., when item like ship
     // is added, there might already be affector specs which should affect
     // it, and in this method we activate such affector specs
    self.activateSpecialAffectorSpecs(affecteeFit: affecteeFit, affecteeItem: affecteeItem)
  }
  
  /// Remove passed affectee item from the register.
  func unregisterAffecteeItem(affecteeItem: BaseItemMixin) {
    self.affectees.remove(affecteeItem)
    guard let affecteeFit = affecteeItem.fit else {
      print("Unregister no fit")
      return
    }
    for (key, storage) in self.getAffecteeStorages(affecteeFit: affecteeFit, affecteeItem: affecteeItem) {
      storage.removeDataEntry(key: key, data: affecteeItem)
    }
    // Deactivate all special affector specs for item being unregistered/
    self.deactivateSpecialAffectorSpecs(affecteeFit: affecteeFit, affecteeItem: affecteeItem)

  }
  
  /// Make the register aware of the local affector spec.
  /// It makes it possible for the affector spec to modify other items within its fit.
  func registerLocalAffectorSpec(affectorSpec: AffectorSpec) {
    guard let storages = self.getLocalAffectorStorages(affectorSpec: affectorSpec) else {
      print("++ RLAS no storages for \(affectorSpec)")
      return
    }
    
    for (key, storage) in storages {
      storage.addDataEntry(key: key, data: affectorSpec)
    }
  }
  
  /// Remove local affector spec from the register.
  /// It makes it impossible for the affector spec to modify any items.
  func unregisterLocalAffectorSpec(affectorSpec: AffectorSpec) {
    guard let storages = self.getLocalAffectorStorages(affectorSpec: affectorSpec) else {
      print("++ RLAS no storages for \(affectorSpec)")
      return
    }
    
    for (key, storage) in storages {
      storage.removeDataEntry(key: key, data: affectorSpec)
    }
  }
  
  /// Make register aware that projected affector spec affects items.
  /// Should be called every time projected effect with modifiers is applied onto any items.
  func registerProjectedAffectorSpec(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol]) {
    let storages = self.getProjectedAffectorStorages(affectorSpec: affectorSpec, targetItems: targetItems)
    
    for (key, storage) in storages {
      storage.addDataEntry(key: key, data: affectorSpec as AnyHashable)
    }
  }
  
  /// Remove effect of affector spec from items.
  /// Should be called every time projected effect with modifiers stops affecting any object.
  func unregisterProjectedAffector(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol]) {
    let storages = self.getProjectedAffectorStorages(affectorSpec: affectorSpec, targetItems: targetItems)
    
    for (key, storage) in storages {
      storage.removeDataEntry(key: key, data: affectorSpec as AnyHashable)
    }
  }
  
  func getLocalAffecteesSelf(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol] {
    return [affectorSpec.itemType]
  }
  
  func getLocalAffecteesCharacter(affectorSpec: AffectorSpec) -> [Character]? {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      print("++ GLAC no fit")
      return nil
    }
    guard let affecteeCharacter = affecteeFit.character else {
      print("++ GLAC no Character")
      return nil
    }
    
    guard self.affectees.contains(affecteeCharacter) else {
      return nil
    }
    
    return [affecteeCharacter]
  }
  
  func getLocalAffecteesShip(affectorSpec: AffectorSpec) -> [Ship]? {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      print("++ GLAS no fit")
      return nil
    }
    guard let affecteeShip = affecteeFit.ship else {
      print("++ GLAS no Ship")
      return nil
    }
    
    guard self.affectees.contains(affecteeShip) else {
      return nil
    }
    
    return [affecteeShip]
  }
  
  func getLocalAffecteesOther(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol] {
    // return [i for i in affector_spec.item._others if i in self.__affectees]
    return Array(affectorSpec.itemType.others.filter({ self.affectees.contains($0)}))
  }
  
  func getAffecteesDomain(affecteeDomain: ModDomain, affecteeFits: [Fit]) -> Set<AnyHashable> {
    var affecteeItems: Set<AnyHashable> = []
    let storage = self.affecteesDomain
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain) as! AnyHashable
      affecteeItems.insert(storage.dictionary[key, default: []])
    }
    return affecteeItems
  }
  
  func getAffecteesDomainGroup(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> Set<AnyHashable> {
    let affecteeGroupId = affectorSpec.modifier.affecteeFilterExtraArg
    var affecteeItems: Set<AnyHashable> = []
    let storage = self.affecteesDomainGroup
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain, affecteeGroupId) as! AnyHashable
      affecteeItems.insert(storage.dictionary[key, default: []])
    }
    return affecteeItems
  }
  
  func getAffecteesDomainSkillRequirement(
    affectorSpec: AffectorSpec,
    affecteeDomain: ModDomain,
    affecteeFits: [Fit]
  ) -> Set<AnyHashable> {
    var affecteeSourceRequirementTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if affecteeSourceRequirementTypeId == Int64(EosTypeId.current_self.rawValue) {
      // check this
      affecteeSourceRequirementTypeId = affectorSpec.itemType.typeId
    }
    var affecteeItems: Set<AnyHashable> = []
    let storage = self.affecteesDomainSkillRequirement
    
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain, affecteeSourceRequirementTypeId) as! AnyHashable
      affecteeItems.insert(storage.dictionary[key, default: []])
    }
    return affecteeItems
  }
  
  func getAffectersOwnerSkillRequirement(
    affectorSpec: AffectorSpec,
    affecteeDomain: ModDomain?,
    affecteeFits: [Fit]
  ) -> Set<AnyHashable> {
    var affecteeSourceRequirementTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if affecteeSourceRequirementTypeId == Int64(EosTypeId.current_self.rawValue) {
      // check this
      affecteeSourceRequirementTypeId = affectorSpec.itemType.typeId
    }
    
    var affecteeItems: Set<AnyHashable> = []
    let storage = self.affecteesOwnerSkillRequirement
    
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeSourceRequirementTypeId) as! AnyHashable
      affecteeItems.insert(storage.dictionary[key, default: []])
    }
    return affecteeItems
  }
  

  /*
   Return all places where passed affectee item should be stored.

    Returns:
        Iterable with multiple elements, where each element is tuple in
        (key, affectee map) format.
   */
  func getAffecteeStorages(affecteeFit: Fit, affecteeItem: any BaseItemMixinProtocol) -> [(AnyHashable, KeyedStorage)] {
    var storages: [(AnyHashable, KeyedStorage)] = []
    guard let affecteeDomain = affecteeItem.modifierDomain else {
      return []
    }
    // Domain
    var key: AnyHashable = (affecteeFit, affecteeDomain) as! AnyHashable
    var storage = self.affecteesDomain
    storages.append((key, storage))
    
    // Domain and group
    let affecteeGroupId = affecteeItem.itemType?.groupId
    if let affecteeGroupId {
      key = (affecteeFit, affecteeDomain, affecteeGroupId) as! AnyHashable
      storage = self.affecteesDomainGroup
      storages.append((key, storage))
    }
    
    // Domain and skill requirement
    storage = self.affecteesDomainSkillRequirement
    for affecteeSkillRequirementTypeId in affecteeItem.itemType?.requiredSkills ?? [:] {
      key = (affecteeFit, affecteeDomain, affecteeSkillRequirementTypeId) as! AnyHashable
      storages.append((key, storage))
    }
    // Owner-modifiable and skill requirement
    if affecteeItem.ownerModifiable {
      storage = self.affecteesOwnerSkillRequirement
      for affecteeSkillRequirementTypeId in affecteeItem.itemType?.requiredSkills ?? [:] {
        key = (affecteeFit, affecteeSkillRequirementTypeId) as! AnyHashable
        storages.append((key, storage))
      }
    }
    return storages

  }
  
  /// Activate special affector specs which should affect passed item.
  func activateSpecialAffectorSpecs(affecteeFit: Fit, affecteeItem: any BaseItemMixinProtocol) {
    var awaitingToActivate: Set<AffectorSpec> = []
    let key = affecteeFit as! AnyHashable
    for affectorSpec in self.affectorsItemAwaiting.dictionary[affecteeFit as! AnyHashable, default: []]
      .compactMap({ $0 as? AffectorSpec })
    {
      let affecteeDomain = affectorSpec.modifier.affecteeDomain
      if affecteeDomain == ModDomain.ship, affecteeItem is Ship {
        awaitingToActivate.insert(affectorSpec)
      } else if affecteeDomain == ModDomain.character, affecteeItem is Character {
        awaitingToActivate.insert(affectorSpec)
      } else if affecteeDomain == ModDomain.me {
        print("++ CHECK HERE MAYBE ISSUE")
        awaitingToActivate.insert(affectorSpec)
      }
    }
    
    if !awaitingToActivate.isEmpty {
      
      self.affectorsItemAwaiting.removeDataSet(key: key, dataSet: awaitingToActivate.map { $0 as AnyHashable})
      self.affectorsItemActive.addDataSet(key: key, dataSet: awaitingToActivate.map { $0 as AnyHashable})
    }
    
    // Other
    var otherToActivate: Set<AffectorSpec> = []
    
    for (affectorItem, affectorSpecs) in self.affectorsItemOther.dictionary {
      if let foo = affectorItem as? BaseItemMixin {
        if foo.others.contains(where: { $0 === affecteeItem }) {
          for value in affectorSpecs.compactMap({ $0 as? AffectorSpec }) {
            otherToActivate.insert(value)
          }
          
        }
      }
    }
    
    if !otherToActivate.isEmpty {
      self.affectorsItemActive.addDataSet(key: key, dataSet: otherToActivate.map { $0 as AnyHashable })
    }
  }
  
  /// Deactivate special affector specs which affect passed item.
  func deactivateSpecialAffectorSpecs(affecteeFit: Fit, affecteeItem: BaseItemMixin) {
    if self.affectorsItemActive.dictionary[affecteeItem] == nil {
      return
    }
    var awaitableToDeactivate: Set<AffectorSpec> = []
    
    for affectorSpec in self.affectorsItemActive.dictionary[affecteeItem, default: []]
      .compactMap({ $0 as? AffectorSpec })
    {
      if [ModDomain.ship, ModDomain.character, ModDomain.me].contains(affectorSpec.modifier.affecteeDomain) {
        awaitableToDeactivate.insert(affectorSpec)
      }
    }
    
    self.affectorsItemActive.dictionary.removeValue(forKey: affecteeItem)
    
    if !awaitableToDeactivate.isEmpty {
      self.affectorsItemAwaiting.addDataSet(key: affecteeFit as! AnyHashable, dataSet: Array(awaitableToDeactivate))
    }
  }

  /// Get Places where passed local affector spec should be stored.
  func getLocalAffectorStorages(affectorSpec: AffectorSpec) -> [(AnyHashable, KeyedStorage)]? {

    let affecteeFilter = affectorSpec.modifier.affecteeFilter
    
    
    if affecteeFilter == ModAffecteeFilter.item {
      let affecteeDomain = affectorSpec.modifier.affecteeDomain
      switch affecteeDomain {
      case .me: return getLocalAffectorStoragesSelf(affectorSpec: affectorSpec)
      case .character: return getLocalAffectorStoragesCharacter(affectorSpec: affectorSpec)
      case .ship: return getLocalAffectorStoragesShip(affectorSpec: affectorSpec)
      case .other: return getLocalAffectorStoragesOther(affectorSpec: affectorSpec)
      default: return nil
      }
    } else {
      guard let affecteeDomain = self.resolveLocalDomain(affectorSpec: affectorSpec) else {
        print("++ GLAS no affecteeDomain")
        return nil
      }
      let affecteeFits = [affectorSpec.itemType.fit].compactMap { $0 }
      switch affecteeFilter {
      case .domain: return getAffectorStoragesDomain(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .domain_group: return getAffectorStoragesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .domain_skillrq: return getAffectorStoragesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .owner_skillrq: return getAffectorStoragesOwnerSkillRequirements(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      default: return nil
      }
    }
    
  }
  
  /// Convert relative domain into absolute for local affector spec.
  /// Applicable only to en-masse modifications - that is, when modification affects multiple items in affectee domain.
  func resolveLocalDomain(affectorSpec: AffectorSpec) -> ModDomain? {
    let affectorItem = affectorSpec.itemType
    let affecteeDomain = affectorSpec.modifier.affecteeDomain
    switch affecteeDomain {
    case .me :
      if affectorItem is Ship {
        return .ship
      } else if affectorItem is Character {
        return .character
      } else {
        return nil // throw?
      }
    case .character, .ship:
      return affecteeDomain
    default: return nil // throw?
    }
    /*
      # Just return untouched domain for all other valid cases. Valid cases
      # include 'globally' visible (within the fit scope) domains only. I.e.
      # if item on fit refers this affectee domain, it should always refer the
      # same affectee item regardless of position of source item.
     */
  }
  
  /// Get places where passed projected affector spec should be stored.
  func getProjectedAffectorStorages(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol]) -> [(AnyHashable, KeyedStorage)] {
    
    var affecteeFilter = affectorSpec.modifier.affecteeFilter
    //  # Modifier affects just targeted items directly
    if affecteeFilter == .item {
      var storages: [(AnyHashable, KeyedStorage)] = []
      let storage = affectorsItemActive
      
      for targetItem in targetItems.compactMap({ $0 as? BaseItemMixin}) {
        if self.affectees.contains(targetItem) {
          let key: AnyHashable = targetItem as AnyHashable
          storages.append((key, storage))
        }
      }
      return storages
    } else {
      let affecteeDomain = ModDomain.ship
      let affecteeFits = targetItems.compactMap({ $0 as? BaseItemMixin }).filter { $0 is Ship}.compactMap { $0.fit }
      switch affecteeFilter {
      case .domain: return getAffectorStoragesDomain(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .domain_group: return getAffectorStoragesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .domain_skillrq: return getAffectorStoragesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      case .owner_skillrq: return getAffectorStoragesOwnerSkillRequirements(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: affecteeFits)
      default: return []
      }
    }
  }
  
  func getLocalAffectorStoragesSelf(affectorSpec: AffectorSpec) -> [(AnyHashable, KeyedStorage)]? {
    guard let affecteeItem = affectorSpec.itemType as? BaseItemMixin else {
      print("++ GLAS-S not BaseItemMixin")
      return nil
    }
    
    let key: AnyHashable
    let storage: KeyedStorage
    
    if self.affectees.contains(affecteeItem) {
      key = affecteeItem as AnyHashable
      storage = self.affectorsItemActive
    } else {
      guard let fit = affecteeItem.fit else {
        print("++ GLAS-S no fit for \(affecteeItem)")
        return nil
      }
      key = fit as! AnyHashable
      storage = self.affectorsItemAwaiting
    }
    return [(key, storage)]
  }
  
  func getLocalAffectorStoragesCharacter(affectorSpec: AffectorSpec) -> [(AnyHashable, KeyedStorage)]? {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      print("++ GLAS-C no affecteeFit")
      return nil
    }
    guard let affecteeCharacter = affecteeFit.character else {
      print("++ no affecteeCharacter")
      return nil
    }
    
    let key: AnyHashable
    let storage: KeyedStorage
    
    if self.affectees.contains(affecteeCharacter) {
      key = affecteeCharacter as AnyHashable
      storage = self.affectorsItemActive
    } else {
      key = affecteeFit as! AnyHashable
      storage = self.affectorsItemAwaiting
    }
    return [(key, storage)]
  }
  
  func getLocalAffectorStoragesShip(affectorSpec: AffectorSpec) -> [(AnyHashable, KeyedStorage)]? {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      print("++ GLACS-S no affecteeFit")
      return nil
    }
    guard let affecteeShip = affecteeFit.ship else {
      print("++ no affecteeShip")
      return nil
    }
    
    let key: AnyHashable
    let storage: KeyedStorage
    
    if self.affectees.contains(affecteeShip) {
      key = affecteeShip as AnyHashable
      storage = self.affectorsItemActive
    } else {
      key = affecteeFit as! AnyHashable
      storage = self.affectorsItemAwaiting
    }
    return [(key, storage)]
  }
  
  func getLocalAffectorStoragesOther(affectorSpec: AffectorSpec) -> [(AnyHashable, KeyedStorage)] {
    // Affectors with 'other' modifiers are always stored in their special place
    var storages: [(AnyHashable, KeyedStorage)] = [(affectorSpec.itemType as! AnyHashable, self.affectorsItemOther)]
    
    // And all those which have valid affectee item are also stored in storage for active direct affectors
    let storage = self.affectorsItemActive
    
    for otherItem in affectorSpec.itemType.others {
      if self.affectees.contains(otherItem) {
        let key: AnyHashable = otherItem as AnyHashable
        storages.append((key, storage))
      }
    }
    return storages
  }
  

  func getAffectorStoragesDomain(affectorSpec: AffectorSpec?, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> [(AnyHashable, KeyedStorage)] {
    var storages: [(AnyHashable, KeyedStorage)] = []
    let storage = self.affectorsDomain
    
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain) as! AnyHashable
      storages.append((key, storage))
    }
    return storages
  }
  
  func getAffectorStoragesDomainGroup(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> [(AnyHashable, KeyedStorage)] {
    let affecteeGroupId = affectorSpec.modifier.affecteeFilterExtraArg
    var storages: [(AnyHashable, KeyedStorage)] = []
    let storage = self.affectorsDomainGroup
    
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain, affecteeGroupId) as! AnyHashable
      storages.append((key, storage))
    }
    return storages
  }
  
  func getAffectorStoragesDomainSkillRequirement(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> [(AnyHashable, KeyedStorage)] {
    var affecteeSkillRequirementTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if affecteeSkillRequirementTypeId == Int64(EosTypeId.current_self.rawValue) {
      affecteeSkillRequirementTypeId = affectorSpec.itemType.typeId
    }
    
    var storages: [(AnyHashable, KeyedStorage)] = []
    let storage = self.affectorsDomainSkillRequirement
    
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain, affecteeSkillRequirementTypeId) as! AnyHashable
      storages.append((key, storage))
    }
    return storages
  }
  
  func getAffectorStoragesOwnerSkillRequirements(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> [(AnyHashable, KeyedStorage)] {
    var affecteeSkillRequirementTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if affecteeSkillRequirementTypeId == Int64(EosTypeId.current_self.rawValue) {
      affecteeSkillRequirementTypeId = affectorSpec.itemType.typeId
    }
    
    var storages: [(AnyHashable, KeyedStorage)] = []
    let storage = self.affectorsOwnerSkillRequirement
    for affecteeFit in affecteeFits {
      let key: AnyHashable = (affecteeFit, affecteeDomain, affecteeSkillRequirementTypeId) as! AnyHashable
      storages.append((key, storage))
    }
    return storages
  }
  
  /// Convert relative domain into absolute for local affector spec.
  ///
  /// Applicable only to en-masse modifications - that is, when modification affects multiple items in affectee domain.
  func handleResolveDomain(affectorSpec: AffectorSpec) -> ModDomain? {

    let affectorItem = affectorSpec.itemType
    let affecteeDomain = affectorSpec.modifier.affecteeDomain
    
    switch affecteeDomain {
    case .me:
      if affectorItem is Ship {
        return .ship
      } else if affectorItem is Character {
        return .character
      } else {
        fatalError("UnexpectedDomainError(\(affecteeDomain))")
      }
    case .character, .ship:
      return affecteeDomain
    default: return nil
    }
  }
  
  func handleAffectorSpecErrors(error: Any, affectorSpec: AffectorSpec) {
    /*
     """Handles exceptions related to affector spec.

     Multiple register methods which get data based on passed affector spec
     raise similar exceptions. To handle them in consistent fashion, it is
     done from this method. If error cannot be handled by the method, it is
     re-raised.
     """
     if isinstance(error, UnexpectedDomainError):
         msg = (
             'malformed modifier on item type {}: '
             'unsupported affectee domain {}'
         ).format(affector_spec.item._type_id, error.args[0])
         logger.warning(msg)
     elif isinstance(error, UnknownAffecteeFilterError):
         msg = (
             'malformed modifier on item type {}: invalid affectee filter {}'
         ).format(affector_spec.item._type_id, error.args[0])
         logger.warning(msg)
     else:
         raise error
     */
  }
}
