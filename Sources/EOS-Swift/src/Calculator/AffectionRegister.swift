//
//  AffectionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//
import Foundation

// MARK: - Key Structs

/// Key for affecteesDomainGroup: domain + groupId
struct DomainGroupKey: Hashable {
  let affecteeDomain: ModDomain
  let groupID: Int64
}

// Kept for backward compatibility during transition
typealias Key1 = DomainGroupKey

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

struct AffectorSpec: Hashable {
  public var modifier: any BaseModifierProtocol
  public var effect: Effect
  public var itemType: any BaseItemMixinProtocol

  static func == (lhs: AffectorSpec, rhs: AffectorSpec) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(modifier)
    hasher.combine(effect)
    hasher.combine(itemType)
  }
}

struct AffectorModifier: Hashable {
  let affecteeFilter: ModAffecteeFilter
  let modDomain: ModDomain
  let affecteeFilterExtraArg: Int64
  let affecteeDomain: ModDomain
  let affecteeAtributeId: AttrId
}

/// Key for affectorsDomain: (fitID, domain)
struct FitDomainKey: Hashable {
  let fitID: Int64
  let domain: ModDomain
}

/// Key for affecteesOwnerSkillRequirement: (fitID, skillTypeId)
struct FitTypeIdKey: Hashable {
  let fitID: Int64
  let typeId: Int64
}

// MARK: - AffectionRegister

class AffectionRegister {
  var affectees: Set<BaseItemMixin> = []

  // Affectee storages: track which items belong to which domain/group/etc
  var affecteesDomain = KeyedStorage<ModDomain, BaseItemMixin>()
  var affecteesDomainGroup = KeyedStorage<DomainGroupKey, BaseItemMixin>()
  var affecteesDomainSkillRequirement = KeyedStorage<DomainSkillKey, BaseItemMixin>()
  var affecteesOwnerSkillRequirement = KeyedStorage<FitTypeIdKey, BaseItemMixin>()

  // Affector storages: track which affector specs affect which items/domains
  var affectorsItemOther = KeyedStorage<BaseItemMixin, AffectorSpec>()
  var affectorsItemAwaiting = KeyedStorage<Int64, AffectorSpec>()    // keyed by fit.id
  var affectorsItemActive = KeyedStorage<BaseItemMixin, AffectorSpec>()
  var affectorsDomain = KeyedStorage<FitDomainKey, AffectorSpec>()
  var affectorsDomainGroup = KeyedStorage<DomainGroupKey, AffectorSpec>()
  var affectorsDomainSkillRequirement = KeyedStorage<DomainSkillKey, AffectorSpec>()
  var affectorsOwnerSkillRequirement = KeyedStorage<DomainSkillKey, AffectorSpec>()

  init() { }

  // MARK: - Public: Affectee Queries

  /// Get iterable with items influenced by passed local affector spec.
  func getLocalAffecteeItems(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol]? {
    let affecteeFilter = affectorSpec.modifier.affecteeFilter

    if affecteeFilter == .item {
      switch affectorSpec.modifier.affecteeDomain {
      case .me:        return getLocalAffecteesSelf(affectorSpec: affectorSpec)
      case .character: return getLocalAffecteesCharacter(affectorSpec: affectorSpec)
      case .ship:      return getLocalAffecteesShip(affectorSpec: affectorSpec)
      case .other:     return getLocalAffecteesOther(affectorSpec: affectorSpec)
      default:         return nil
      }
    } else {
      guard let affecteeDomain = resolveLocalDomain(affectorSpec: affectorSpec),
            let affecteeFit = affectorSpec.itemType.fit else { return nil }
      let fits = [affecteeFit]
      switch affecteeFilter {
      case .domain:
        return Array(getAffecteesDomain(affecteeDomain: affecteeDomain, affecteeFits: fits))
      case .domain_group:
        return Array(getAffecteesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits))
      case .domain_skillrq:
        return Array(getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits))
      case .owner_skillrq:
        return Array(getAffecteesOwnerSkillRequirement(affectorSpec: affectorSpec, affecteeFits: fits))
      default: return nil
      }
    }
  }

  /// Get iterable with items influenced by projected affector spec.
  func getProjectedAffecteeItems(affectorSpec: AffectorSpec, targetItems: [BaseItemMixin]) -> [any BaseItemMixinProtocol]? {
    let affecteeFilter = affectorSpec.modifier.affecteeFilter

    if affecteeFilter == .item {
      return targetItems.filter { self.affectees.contains($0) }
    } else {
      let affecteeFits = targetItems.filter { $0 is Ship }.compactMap { $0.fit }
      switch affecteeFilter {
      case .domain:
        return Array(getAffecteesDomain(affecteeDomain: .ship, affecteeFits: affecteeFits))
      case .domain_group:
        return Array(getAffecteesDomainGroup(affectorSpec: affectorSpec, affecteeDomain: .ship, affecteeFits: affecteeFits))
      case .domain_skillrq:
        return Array(getAffecteesDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: .ship, affecteeFits: affecteeFits))
      case .owner_skillrq:
        return Array(getAffecteesOwnerSkillRequirement(affectorSpec: affectorSpec, affecteeFits: affecteeFits))
      default: return nil
      }
    }
  }

  func getAffectorSpecs(affecteeItem: any BaseItemMixinProtocol) -> Set<AffectorSpec>? {
    guard let concreteItem = affecteeItem as? BaseItemMixin else { return nil }
    var affectorSpecs = Set<AffectorSpec>()

    // Direct item affectors (active)
    affectorSpecs.formUnion(affectorsItemActive.dictionary[concreteItem, default: []])

    guard let affecteeDomain = affecteeItem.modifierDomain else { return nil }

    // Domain affectors — keyed by (fit, domain)
    if let affecteeFit = affecteeItem.fit {
      let domainKey = FitDomainKey(fitID: affecteeFit.id, domain: affecteeDomain)
      affectorSpecs.formUnion(affectorsDomain.dictionary[domainKey, default: []])
    }

    // Domain and group affectors
    if let groupId = affecteeItem.itemType?.groupId {
      let groupKey = DomainGroupKey(affecteeDomain: affecteeDomain, groupID: groupId)
      affectorSpecs.formUnion(affectorsDomainGroup.dictionary[groupKey, default: []])
    }

    // Domain and skill requirement affectors
    guard let requiredSkills = affecteeItem.itemType?.requiredSkills else { return nil }
    for skillReq in requiredSkills {
      let key = DomainSkillKey(affecteeDomain: affecteeDomain, affecteeSkillRequirementTypeId: skillReq.value)
      affectorSpecs.formUnion(affectorsDomainSkillRequirement.dictionary[key, default: []])
    }

    return affectorSpecs
  }

  // MARK: - Public: Register / Unregister Affectees

  /// Add passed affectee item to the register.
  func registerAffecteeItem(affecteeItem: BaseItemMixin) {
    if affecteeItem.itemType?.name == "EM Shield Hardener II" {
      print("^^ registerAffecteeItem \(affecteeItem)")
    }
    self.affectees.insert(affecteeItem)
    guard let affecteeFit = affecteeItem.fit else { return }
    addToAffecteeStorages(affecteeFit: affecteeFit, affecteeItem: affecteeItem)
    self.activateSpecialAffectorSpecs(affecteeFit: affecteeFit, affecteeItem: affecteeItem)
  }

  /// Remove passed affectee item from the register.
  func unregisterAffecteeItem(affecteeItem: BaseItemMixin) {
    self.affectees.remove(affecteeItem)
    guard let affecteeFit = affecteeItem.fit else { return }
    removeFromAffecteeStorages(affecteeFit: affecteeFit, affecteeItem: affecteeItem)
    self.deactivateSpecialAffectorSpecs(affecteeFit: affecteeFit, affecteeItem: affecteeItem)
  }

  // MARK: - Public: Register / Unregister Local Affectors

  /// Make the register aware of the local affector spec.
  func registerLocalAffectorSpec(affectorSpec: AffectorSpec) {
    applyToLocalAffectorStorages(affectorSpec: affectorSpec, add: true)
  }

  /// Remove local affector spec from the register.
  func unregisterLocalAffectorSpec(affectorSpec: AffectorSpec) {
    applyToLocalAffectorStorages(affectorSpec: affectorSpec, add: false)
  }

  // MARK: - Public: Register / Unregister Projected Affectors

  /// Make register aware that projected affector spec affects items.
  func registerProjectedAffectorSpec(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol]) {
    applyToProjectedAffectorStorages(affectorSpec: affectorSpec, targetItems: targetItems, add: true)
  }

  /// Remove effect of affector spec from items.
  func unregisterProjectedAffector(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol]) {
    applyToProjectedAffectorStorages(affectorSpec: affectorSpec, targetItems: targetItems, add: false)
  }

  // MARK: - Affectee Lookup Helpers

  func getLocalAffecteesSelf(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol] {
    return [affectorSpec.itemType]
  }

  func getLocalAffecteesCharacter(affectorSpec: AffectorSpec) -> [Character]? {
    guard let affecteeFit = affectorSpec.itemType.fit,
          let affecteeCharacter = affecteeFit.character,
          self.affectees.contains(affecteeCharacter) else { return nil }
    return [affecteeCharacter]
  }

  func getLocalAffecteesShip(affectorSpec: AffectorSpec) -> [Ship]? {
    guard let affecteeFit = affectorSpec.itemType.fit,
          let affecteeShip = affecteeFit.ship,
          self.affectees.contains(affecteeShip) else { return nil }
    return [affecteeShip]
  }

  func getLocalAffecteesOther(affectorSpec: AffectorSpec) -> [any BaseItemMixinProtocol] {
    return Array(affectorSpec.itemType.others.filter { self.affectees.contains($0) })
  }

  func getAffecteesDomain(affecteeDomain: ModDomain, affecteeFits: [Fit]) -> Set<BaseItemMixin> {
    return affecteesDomain.dictionary[affecteeDomain, default: []]
  }

  func getAffecteesDomainGroup(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit]) -> Set<BaseItemMixin> {
    guard let groupId = affectorSpec.modifier.affecteeFilterExtraArg else { return [] }
    let key = DomainGroupKey(affecteeDomain: affecteeDomain, groupID: groupId)
    return affecteesDomainGroup.dictionary[key, default: []]
  }

  func getAffecteesDomainSkillRequirement(
    affectorSpec: AffectorSpec,
    affecteeDomain: ModDomain,
    affecteeFits: [Fit]
  ) -> Set<BaseItemMixin> {
    var skillTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if skillTypeId == Int64(EosTypeId.current_self.rawValue) {
      skillTypeId = affectorSpec.itemType.typeId
    }
    guard let skillTypeId else { return [] }
    let key = DomainSkillKey(affecteeDomain: affecteeDomain, affecteeSkillRequirementTypeId: skillTypeId)
    return affecteesDomainSkillRequirement.dictionary[key, default: []]
  }

  func getAffecteesOwnerSkillRequirement(
    affectorSpec: AffectorSpec,
    affecteeFits: [Fit]
  ) -> Set<BaseItemMixin> {
    var skillTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if skillTypeId == Int64(EosTypeId.current_self.rawValue) {
      skillTypeId = affectorSpec.itemType.typeId
    }
    guard let skillTypeId else { return [] }
    var result = Set<BaseItemMixin>()
    for fit in affecteeFits {
      let key = FitTypeIdKey(fitID: fit.id, typeId: skillTypeId)
      result.formUnion(affecteesOwnerSkillRequirement.dictionary[key, default: []])
    }
    return result
  }

  // MARK: - Activate / Deactivate Special Affectors

  /// Activate special affector specs which should affect passed item.
  func activateSpecialAffectorSpecs(affecteeFit: Fit, affecteeItem: any BaseItemMixinProtocol) {
    var awaitingToActivate = Set<AffectorSpec>()

    for affectorSpec in self.affectorsItemAwaiting.dictionary[affecteeFit.id, default: []] {
      let affecteeDomain = affectorSpec.modifier.affecteeDomain
      if affecteeDomain == .ship, affecteeItem is Ship {
        awaitingToActivate.insert(affectorSpec)
      } else if affecteeDomain == .character, affecteeItem is Character {
        awaitingToActivate.insert(affectorSpec)
      } else if affecteeDomain == .me {
        print("++ CHECK HERE MAYBE ISSUE")
        awaitingToActivate.insert(affectorSpec)
      }
    }

    if !awaitingToActivate.isEmpty, let concreteItem = affecteeItem as? BaseItemMixin {
      self.affectorsItemAwaiting.removeDataSet(key: affecteeFit.id, dataSet: Array(awaitingToActivate))
      self.affectorsItemActive.addDataSet(key: concreteItem, dataSet: Array(awaitingToActivate))
    }

    // Other: activate affector specs targeting this item via 'other' relationship
    var otherToActivate = Set<AffectorSpec>()
    for (affectorItem, affectorSpecs) in self.affectorsItemOther.dictionary {
      if affectorItem.others.contains(where: { $0 === affecteeItem }) {
        otherToActivate.formUnion(affectorSpecs)
      }
    }

    if !otherToActivate.isEmpty, let concreteItem = affecteeItem as? BaseItemMixin {
      self.affectorsItemActive.addDataSet(key: concreteItem, dataSet: Array(otherToActivate))
    }
  }

  /// Deactivate special affector specs which affect passed item.
  func deactivateSpecialAffectorSpecs(affecteeFit: Fit, affecteeItem: BaseItemMixin) {
    guard let activeSpecs = self.affectorsItemActive.dictionary[affecteeItem] else { return }

    let awaitableToDeactivate = activeSpecs.filter {
      [ModDomain.ship, .character, .me].contains($0.modifier.affecteeDomain)
    }

    self.affectorsItemActive.dictionary.removeValue(forKey: affecteeItem)

    if !awaitableToDeactivate.isEmpty {
      self.affectorsItemAwaiting.addDataSet(key: affecteeFit.id, dataSet: Array(awaitableToDeactivate))
    }
  }

  // MARK: - Domain Resolution

  /// Convert relative domain into absolute for local affector spec.
  func resolveLocalDomain(affectorSpec: AffectorSpec) -> ModDomain? {
    let affectorItem = affectorSpec.itemType
    switch affectorSpec.modifier.affecteeDomain {
    case .me:
      if affectorItem is Ship      { return .ship }
      if affectorItem is Character { return .character }
      return nil
    case .character, .ship:
      return affectorSpec.modifier.affecteeDomain
    default: return nil
    }
  }

  func handleResolveDomain(affectorSpec: AffectorSpec) -> ModDomain? {
    let affectorItem = affectorSpec.itemType
    switch affectorSpec.modifier.affecteeDomain {
    case .me:
      if affectorItem is Ship      { return .ship }
      if affectorItem is Character { return .character }
      fatalError("UnexpectedDomainError(\(String(describing: affectorSpec.modifier.affecteeDomain)))")
    case .character, .ship:
      return affectorSpec.modifier.affecteeDomain
    default: return nil
    }
  }

  func handleAffectorSpecErrors(error: Any, affectorSpec: AffectorSpec) { }

  // MARK: - Private: Affectee Storage Operations

  private func addToAffecteeStorages(affecteeFit: Fit, affecteeItem: BaseItemMixin) {
    guard let affecteeDomain = affecteeItem.modifierDomain else { return }

    affecteesDomain.addDataEntry(key: affecteeDomain, data: affecteeItem)

    if let groupId = affecteeItem.itemType?.groupId {
      affecteesDomainGroup.addDataEntry(
        key: DomainGroupKey(affecteeDomain: affecteeDomain, groupID: groupId),
        data: affecteeItem
      )
    }

    if affecteeItem.ownerModifiable {
      for skillReq in affecteeItem.itemType?.requiredSkills ?? [:] {
        affecteesOwnerSkillRequirement.addDataEntry(
          key: FitTypeIdKey(fitID: affecteeFit.id, typeId: skillReq.key),
          data: affecteeItem
        )
      }
    }
  }

  private func removeFromAffecteeStorages(affecteeFit: Fit, affecteeItem: BaseItemMixin) {
    guard let affecteeDomain = affecteeItem.modifierDomain else { return }

    affecteesDomain.removeDataEntry(key: affecteeDomain, data: affecteeItem)

    if let groupId = affecteeItem.itemType?.groupId {
      affecteesDomainGroup.removeDataEntry(
        key: DomainGroupKey(affecteeDomain: affecteeDomain, groupID: groupId),
        data: affecteeItem
      )
    }

    if affecteeItem.ownerModifiable {
      for skillReq in affecteeItem.itemType?.requiredSkills ?? [:] {
        affecteesOwnerSkillRequirement.removeDataEntry(
          key: FitTypeIdKey(fitID: affecteeFit.id, typeId: skillReq.key),
          data: affecteeItem
        )
      }
    }
  }

  // MARK: - Private: Local Affector Storage Operations

  private func applyToLocalAffectorStorages(affectorSpec: AffectorSpec, add: Bool) {
    let affecteeFilter = affectorSpec.modifier.affecteeFilter

    if affecteeFilter == .item {
      switch affectorSpec.modifier.affecteeDomain {
      case .me:        applyAffectorSelf(affectorSpec: affectorSpec, add: add)
      case .character: applyAffectorCharacter(affectorSpec: affectorSpec, add: add)
      case .ship:      applyAffectorShip(affectorSpec: affectorSpec, add: add)
      case .other:     applyAffectorOther(affectorSpec: affectorSpec, add: add)
      default:
        if !add { print("++ RLAS no storages for \(affectorSpec)") }
      }
    } else {
      guard let affecteeDomain = resolveLocalDomain(affectorSpec: affectorSpec) else {
        if !add { print("++ GLAS no affecteeDomain") }
        return
      }
      let fits = [affectorSpec.itemType.fit].compactMap { $0 }
      switch affecteeFilter {
      case .domain:
        applyAffectorsDomain(affecteeDomain: affecteeDomain, affecteeFits: fits, spec: affectorSpec, add: add)
      case .domain_group:
        applyAffectorsDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      case .domain_skillrq:
        applyAffectorsDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      case .owner_skillrq:
        applyAffectorsOwnerSkillRequirements(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      default:
        if !add { print("++ RLAS no storages for \(affectorSpec)") }
      }
    }
  }

  private func applyAffectorSelf(affectorSpec: AffectorSpec, add: Bool) {
    guard let affecteeItem = affectorSpec.itemType as? BaseItemMixin else {
      if !add { print("++ GLAS-S not BaseItemMixin") }
      return
    }
    if self.affectees.contains(affecteeItem) {
      if add { affectorsItemActive.addDataEntry(key: affecteeItem, data: affectorSpec) }
      else   { affectorsItemActive.removeDataEntry(key: affecteeItem, data: affectorSpec) }
    } else {
      guard let fit = affecteeItem.fit else {
        if !add { print("++ GLAS-S no fit for \(affecteeItem)") }
        return
      }
      if add { affectorsItemAwaiting.addDataEntry(key: fit.id, data: affectorSpec) }
      else   { affectorsItemAwaiting.removeDataEntry(key: fit.id, data: affectorSpec) }
    }
  }

  private func applyAffectorCharacter(affectorSpec: AffectorSpec, add: Bool) {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      if !add { print("++ GLAS-C no affecteeFit") }
      return
    }
    guard let affecteeCharacter = affecteeFit.character else {
      if !add { print("++ no affecteeCharacter") }
      return
    }
    if self.affectees.contains(affecteeCharacter) {
      if add { affectorsItemActive.addDataEntry(key: affecteeCharacter, data: affectorSpec) }
      else   { affectorsItemActive.removeDataEntry(key: affecteeCharacter, data: affectorSpec) }
    } else {
      if add { affectorsItemAwaiting.addDataEntry(key: affecteeFit.id, data: affectorSpec) }
      else   { affectorsItemAwaiting.removeDataEntry(key: affecteeFit.id, data: affectorSpec) }
    }
  }

  private func applyAffectorShip(affectorSpec: AffectorSpec, add: Bool) {
    guard let affecteeFit = affectorSpec.itemType.fit else {
      if !add { print("++ GLACS-S no affecteeFit") }
      return
    }
    guard let affecteeShip = affecteeFit.ship else {
      if !add { print("++ no affecteeShip") }
      return
    }
    if self.affectees.contains(affecteeShip) {
      if add { affectorsItemActive.addDataEntry(key: affecteeShip, data: affectorSpec) }
      else   { affectorsItemActive.removeDataEntry(key: affecteeShip, data: affectorSpec) }
    } else {
      if add { affectorsItemAwaiting.addDataEntry(key: affecteeFit.id, data: affectorSpec) }
      else   { affectorsItemAwaiting.removeDataEntry(key: affecteeFit.id, data: affectorSpec) }
    }
  }

  private func applyAffectorOther(affectorSpec: AffectorSpec, add: Bool) {
    guard let affectorItem = affectorSpec.itemType as? BaseItemMixin else { return }
    // 'other' affectors live in their special storage regardless of affectee state
    if add { affectorsItemOther.addDataEntry(key: affectorItem, data: affectorSpec) }
    else   { affectorsItemOther.removeDataEntry(key: affectorItem, data: affectorSpec) }

    // Also touch active storage for already-tracked 'other' items
    for otherItem in affectorSpec.itemType.others {
      if self.affectees.contains(otherItem) {
        if add { affectorsItemActive.addDataEntry(key: otherItem, data: affectorSpec) }
        else   { affectorsItemActive.removeDataEntry(key: otherItem, data: affectorSpec) }
      }
    }
  }

  // MARK: - Private: En-Masse Affector Storage Operations

  private func applyAffectorsDomain(affecteeDomain: ModDomain, affecteeFits: [Fit], spec: AffectorSpec, add: Bool) {
    for fit in affecteeFits {
      let key = FitDomainKey(fitID: fit.id, domain: affecteeDomain)
      if add { affectorsDomain.addDataEntry(key: key, data: spec) }
      else   { affectorsDomain.removeDataEntry(key: key, data: spec) }
    }
  }

  private func applyAffectorsDomainGroup(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit], add: Bool) {
    guard let groupId = affectorSpec.modifier.affecteeFilterExtraArg else { return }
    let key = DomainGroupKey(affecteeDomain: affecteeDomain, groupID: groupId)
    for _ in affecteeFits {
      if add { affectorsDomainGroup.addDataEntry(key: key, data: affectorSpec) }
      else   { affectorsDomainGroup.removeDataEntry(key: key, data: affectorSpec) }
    }
  }

  private func applyAffectorsDomainSkillRequirement(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit], add: Bool) {
    var skillTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if skillTypeId == Int64(EosTypeId.current_self.rawValue) { skillTypeId = affectorSpec.itemType.typeId }
    guard let skillTypeId else { return }
    let key = DomainSkillKey(affecteeDomain: affecteeDomain, affecteeSkillRequirementTypeId: skillTypeId)
    for _ in affecteeFits {
      if add { affectorsDomainSkillRequirement.addDataEntry(key: key, data: affectorSpec) }
      else   { affectorsDomainSkillRequirement.removeDataEntry(key: key, data: affectorSpec) }
    }
  }

  private func applyAffectorsOwnerSkillRequirements(affectorSpec: AffectorSpec, affecteeDomain: ModDomain, affecteeFits: [Fit], add: Bool) {
    var skillTypeId = affectorSpec.modifier.affecteeFilterExtraArg
    if skillTypeId == Int64(EosTypeId.current_self.rawValue) { skillTypeId = affectorSpec.itemType.typeId }
    guard let skillTypeId else { return }
    let key = DomainSkillKey(affecteeDomain: affecteeDomain, affecteeSkillRequirementTypeId: skillTypeId)
    for _ in affecteeFits {
      if add { affectorsOwnerSkillRequirement.addDataEntry(key: key, data: affectorSpec) }
      else   { affectorsOwnerSkillRequirement.removeDataEntry(key: key, data: affectorSpec) }
    }
  }

  // MARK: - Private: Projected Affector Storage Operations

  private func applyToProjectedAffectorStorages(affectorSpec: AffectorSpec, targetItems: [any BaseItemMixinProtocol], add: Bool) {
    let affecteeFilter = affectorSpec.modifier.affecteeFilter

    if affecteeFilter == .item {
      for targetItem in targetItems.compactMap({ $0 as? BaseItemMixin }) {
        if self.affectees.contains(targetItem) {
          if add { affectorsItemActive.addDataEntry(key: targetItem, data: affectorSpec) }
          else   { affectorsItemActive.removeDataEntry(key: targetItem, data: affectorSpec) }
        }
      }
    } else {
      let affecteeDomain = ModDomain.ship
      let fits = targetItems.compactMap { $0 as? BaseItemMixin }.filter { $0 is Ship }.compactMap { $0.fit }
      switch affecteeFilter {
      case .domain:
        applyAffectorsDomain(affecteeDomain: affecteeDomain, affecteeFits: fits, spec: affectorSpec, add: add)
      case .domain_group:
        applyAffectorsDomainGroup(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      case .domain_skillrq:
        applyAffectorsDomainSkillRequirement(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      case .owner_skillrq:
        applyAffectorsOwnerSkillRequirements(affectorSpec: affectorSpec, affecteeDomain: affecteeDomain, affecteeFits: fits, add: add)
      default: break
      }
    }
  }
}

// MARK: - Additional Key Structs

/// Key for affectorsDomainSkillRequirement: domain + skillTypeId
struct DomainSkillKey: Hashable {
  let affecteeDomain: ModDomain
  let affecteeSkillRequirementTypeId: Int64
}

/// General-purpose key for (Int64, Int64) pairs, e.g. (typeID, attributeID).
struct KeyValueKey: Hashable {
  let key: Int64
  let value: Int64
}
