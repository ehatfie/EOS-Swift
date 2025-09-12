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
    hasher.combine(self)
  }
  
  let item: any BaseItemMixinProtocol
  let effect: BaseRepairEffect
}

struct AffecteeDomain: Hashable {
  static func == (lhs: AffecteeDomain, rhs: AffecteeDomain) -> Bool {
    return lhs.effect == rhs.effect
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self)
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

struct AffectorSpec {
  var modifier: AffectorModifier
}

struct AffectorModifier {
  let affecteeFilter: ModAffecteeFilter
  let modDomain: ModDomain
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
  var affectorsDomainSkillRequriment = KeyedStorage()
  var affactorsOwnerSkillRequirement = KeyedStorage()
  
  init() {
    
  }
  
  /*
   __local_affectees_getters = {
       ModDomain.self: __get_local_affectees_self,
       ModDomain.character: __get_local_affectees_character,
       ModDomain.ship: __get_local_affectees_ship,
       ModDomain.other: __get_local_affectees_other}
   */
  
  func getLocalAffecteeItems(affectorSpec: Any) {
    /*
     """Get iterable with items influenced by passed local affector spec."""
     try:
         affectee_filter = affector_spec.modifier.affectee_filter
         # Direct item modification needs to use local-specific getters
         if affectee_filter == ModAffecteeFilter.item:
             affectee_domain = affector_spec.modifier.affectee_domain
             try:
                 getter = self.__local_affectees_getters[affectee_domain]
             except KeyError as e:
                 raise UnexpectedDomainError(affectee_domain) from e
             return getter(self, affector_spec)
         # En-masse filtered modification can use shared affectee item
         # getters
         else:
             try:
                 getter = self.__affectees_getters[affectee_filter]
             except KeyError as e:
                 raise UnknownAffecteeFilterError(affectee_filter) from e
             affectee_domain = self.__resolve_local_domain(affector_spec)
             affectee_fits = affector_spec.item._fit,
             return getter(
                 self, affector_spec, affectee_domain, affectee_fits)
     except Exception as e:
         self.__handle_affector_spec_errors(e, affector_spec)
         return ()
     */
  }
  
  func getProjectedAffecteeItems(affectorSpec: AffectorSpec, targetItems: Any) {
    
    /*
     """Get iterable with items influenced by projected affector spec."""
     affectee_filter = affector_spec.modifier.affectee_filter
     # Return targeted items when modification affects just them directly
     if affectee_filter == ModAffecteeFilter.item:
         return {i for i in tgt_items if i in self.__affectees}
     # En-masse modifications of items located on targeted items use shared
     # affectee item getters
     else:
         try:
             getter = self.__affectees_getters[affectee_filter]
         except KeyError as e:
             raise UnknownAffecteeFilterError(affectee_filter) from e
         affectee_fits = {i._fit for i in tgt_items if isinstance(i, Ship)}
         return getter(self, affector_spec, ModDomain.ship, affectee_fits)
     */
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
    
    
    /*
     if affectee_domain is not None:
         # Domain and skill requirement
         affector_storage = self.__affectors_domain_skillrq
         for affectee_srq_type_id in affectee_item._type.required_skills:
             key = (affectee_fit, affectee_domain, affectee_srq_type_id)
             affector_specs.update(affector_storage.get(key, ()))
     # Owner-modifiable and skill requirement
     if affectee_item._owner_modifiable:
         affector_storage = self.__affectors_owner_skillrq
         for affectee_srq_type_id in affectee_item._type.required_skills:
             key = (affectee_fit, affectee_srq_type_id)
             affector_specs.update(affector_storage.get(key, ()))
     return affector_specs
     */
    
    // Domain and skill requirement
    affectorStorage = self.affectorsDomainSkillRequriment
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
  
  func unregisterAffecteeItem(affecteeItem: Any) {
    /*
     """Remove passed affectee item from the register."""
             self.__affectees.remove(affectee_item)
             affectee_fit = affectee_item._fit
             for key, storage in self.__get_affectee_storages(
                 affectee_fit, affectee_item
             ):
                 storage.rm_data_entry(key, affectee_item)
             # Deactivate all special affector specs for item being unregistered
             self.__deactivate_special_affector_specs(affectee_fit, affectee_item)
     */
  }
  
  func registerLocalAffectorSpec(affectorSpec: Any) {
    /*
     """Make the register aware of the local affector spec.

             It makes it possible for the affector spec to modify other items within
             its fit.
             """
             try:
                 storages = self.__get_local_affector_storages(affector_spec)
             except Exception as e:
                 self.__handle_affector_spec_errors(e, affector_spec)
             else:
                 for key, storage in storages:
                     storage.add_data_entry(key, affector_spec)
     */
  }
  
  func unregisterLocalAffectorSpec(affectorSpec: Any) {
    /*
     """Remove local affector spec from the register.

     It makes it impossible for the affector spec to modify any items.
     """
     try:
         storages = self.__get_local_affector_storages(affector_spec)
     except Exception as e:
         self.__handle_affector_spec_errors(e, affector_spec)
     else:
         for key, storage in storages:
             storage.rm_data_entry(key, affector_spec)
     */
  }
  
  func registerProjectedAffectorSpec(affectorSpec: Any, targetItems: Any) {
    /*
     """Make register aware that projected affector spec affects items.

             Should be called every time projected effect with modifiers is applied
             onto any items.
             """
             try:
                 storages = self.__get_projected_affector_storages(
                     affector_spec, tgt_items)
             except Exception as e:
                 self.__handle_affector_spec_errors(e, affector_spec)
             else:
                 for key, storage in storages:
                     storage.add_data_entry(key, affector_spec)
     */
  }
  
  
  func unregisterProjectedAffector(affectorSpec: Any, targetItems: Any) {
    /*
     """Remove effect of affector spec from items.

     Should be called every time projected effect with modifiers stops
     affecting any object.
     """
     try:
         storages = self.__get_projected_affector_storages(
             affector_spec, tgt_items)
     except Exception as e:
         self.__handle_affector_spec_errors(e, affector_spec)
     else:
         for key, storage in storages:
             storage.rm_data_entry(key, affector_spec)
     */
  }
  
  func getLocalAffecteesSelf(affectorSpec: Any) {
    //return affector_spec.item
  }
  
  func getLocalAffecteesCharacter(affectorSpec: Any) {
    /*
     affectee_fit = affector_spec.item._fit
     affectee_character = affectee_fit.character
     if affectee_character in self.__affectees:
         return affectee_character,
     else:
         return ()
     */
  }
  
  func getLocalAffecteesShip(affectorSpec: Any) {
    /*
     affectee_fit = affector_spec.item._fit
     affectee_ship = affectee_fit.ship
     if affectee_ship in self.__affectees:
         return affectee_ship,
     else:
         return ()
     */
  }
  
  func getLocalAffecteesOther(affectorSpec: Any) {
    // return [i for i in affector_spec.item._others if i in self.__affectees]
  }
  
  /*
   __local_affectees_getters = {
       ModDomain.self: __get_local_affectees_self,
       ModDomain.character: __get_local_affectees_character,
       ModDomain.ship: __get_local_affectees_ship,
       ModDomain.other: __get_local_affectees_other}
   */

  func getAffecteesDomain(affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    var affecteeItems: Set<AnyHashable> = []
    let storage = self.affecteesDomain
    
    /*
     affectee_items = set()
             storage = self.__affectees_domain
             for affectee_fit in affectee_fits:
                 key = (affectee_fit, affectee_domain)
                 affectee_items.update(storage.get(key, ()))
             return affectee_items
     */
  }
  
  func getAffecteesDomainGroup(affectorSpec: Any, affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    /*
     affectee_group_id = affector_spec.modifier.affectee_filter_extra_arg
     affectee_items = set()
     storage = self.__affectees_domain_group
     for affectee_fit in affectee_fits:
         key = (affectee_fit, affectee_domain, affectee_group_id)
         affectee_items.update(storage.get(key, ()))
     return affectee_items
     */
  }
  
  func getAffecteesDomainSkillRequirement(
    affectorSpec: Any,
    affecteeDomain: Any,
    affecteeFits: Any
  ) {
    /*
     affectee_srq_type_id = affector_spec.modifier.affectee_filter_extra_arg
             if affectee_srq_type_id == EosTypeId.current_self:
                 affectee_srq_type_id = affector_spec.item._type_id
             affectee_items = set()
             storage = self.__affectees_domain_skillrq
             for affectee_fit in affectee_fits:
                 key = (affectee_fit, affectee_domain, affectee_srq_type_id)
                 affectee_items.update(storage.get(key, ()))
             return affectee_items
     */
  }
  
  func getAffecteesOwnerSkillRequirement(affectorSpec: Any, affecteeDomain: AffecteeDomain?, affecteeFits: Any) {
    /*
     affectee_srq_type_id = affector_spec.modifier.affectee_filter_extra_arg
             if affectee_srq_type_id == EosTypeId.current_self:
                 affectee_srq_type_id = affector_spec.item._type_id
             affectee_items = set()
             storage = self.__affectees_owner_skillrq
             for affectee_fit in affectee_fits:
                 key = (affectee_fit, affectee_srq_type_id)
                 affectee_items.update(storage.get(key, ()))
             return affectee_items
     */
  }
  
  /*
   __affectees_getters = {
   ModAffecteeFilter.domain: __get_affectees_domain,
   ModAffecteeFilter.domain_group: __get_affectees_domain_group,
   ModAffecteeFilter.domain_skillrq: __get_affectees_domain_skillrq,
   ModAffecteeFilter.owner_skillrq: __get_affectees_owner_skillrq}
   */
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
    var affecteeGroupId = affecteeItem.itemType?.groupId
    if let affecteeGroupId {
      key = (affecteeFit, affecteeDomain, affecteeGroupId) as! AnyHashable
      storage = self.affecteesDomainGroup
      storages.append((key, storage))
    }
    
    // Domain and skill requirement
    storage = self.affecteesDomainSkillRequirement
    for affecteeSkillRequirementTypeId in affecteeItem.itemType?.requiredSkills ?? [] {
      key = (affecteeFit, affecteeDomain, affecteeSkillRequirementTypeId) as! AnyHashable
      storages.append((key, storage))
    }
    // Owner-modifiable and skill requirement
    if affecteeItem.ownerModifiable {
      storage = self.affecteesOwnerSkillRequirement
      for affecteeSkillRequirementTypeId in affecteeItem.itemType?.requiredSkills ?? [] {
        key = (affecteeFit, affecteeSkillRequirementTypeId) as! AnyHashable
        storages.append((key, storage))
      }
    }
    return storages

  }
  
  func activateSpecialAffectorSpecs(affecteeFit: Fit, affecteeItem: any BaseItemMixinProtocol) {
    /*
     """Activate special affector specs which should affect passed item."""
      awaiting_to_activate = set()
      for affector_spec in self.__affectors_item_awaiting.get(
          affectee_fit, ()
      ):
          affectee_domain = affector_spec.modifier.affectee_domain
          # Ship
          if (
              affectee_domain == ModDomain.ship and
              isinstance(affectee_item, Ship)
          ):
              awaiting_to_activate.add(affector_spec)
          # Character
          elif (
              affectee_domain == ModDomain.character and
              isinstance(affectee_item, Character)
          ):
              awaiting_to_activate.add(affector_spec)
          # Self
          elif (
              affectee_domain == ModDomain.self and
              affectee_item is affector_spec.item
          ):
              awaiting_to_activate.add(affector_spec)
      # Move awaiting affector specs from awaiting storage to active storage
      if awaiting_to_activate:
          self.__affectors_item_awaiting.rm_data_set(
              affectee_fit, awaiting_to_activate)
          self.__affectors_item_active.add_data_set(
              affectee_item, awaiting_to_activate)
      # Other
      other_to_activate = set()
      for affector_item, affector_specs in (
          self.__affectors_item_other.items()
      ):
          if affectee_item in affector_item._others:
              other_to_activate.update(affector_specs)
      # Just add affector specs to active storage, 'other' affector specs
      # should never be removed from 'other'-specific storage
      if other_to_activate:
          self.__affectors_item_active.add_data_set(
              affectee_item, other_to_activate)
     */
  }
  
  func deactivateSpecialAffectorSpecs(affecteeFit: Any, affecteeItem: Any) {
    /*
     """Deactivate special affector specs which affect passed item."""
     if affectee_item not in self.__affectors_item_active:
         return
     awaitable_to_deactivate = set()
     for affector_spec in (
         self.__affectors_item_active.get(affectee_item, ())
     ):
         if affector_spec.modifier.affectee_domain in (
             ModDomain.ship, ModDomain.character, ModDomain.self
         ):
             awaitable_to_deactivate.add(affector_spec)
     # Remove all affector specs influencing this item directly, including
     # 'other' affectors
     del self.__affectors_item_active[affectee_item]
     # And make sure awaitable affectors become awaiting - moved to
     # appropriate container for future use
     if awaitable_to_deactivate:
         self.__affectors_item_awaiting.add_data_set(
             affectee_fit, awaitable_to_deactivate)
     */
  }
  
  func getLocalAffectorStorages(affectorSpec: Any) {
    /*
     """Get places where passed local affector spec should be stored.

             Raises:
                 UnexpectedDomainError: If modifier affectee domain is not supported
                     for context of passed affector spec.
                 UnknownAffecteeFilterError: If modifier affectee filter type is not
                     supported.
             """
             affectee_filter = affector_spec.modifier.affectee_filter
             if affectee_filter == ModAffecteeFilter.item:
                 affectee_domain = affector_spec.modifier.affectee_domain
                 try:
                     getter = self.__local_affector_storages_getters[affectee_domain]
                 except KeyError as e:
                     raise UnexpectedDomainError(affectee_domain) from e
                 return getter(self, affector_spec)
             else:
                 try:
                     getter = self.__affector_storages_getters[affectee_filter]
                 except KeyError as e:
                     raise UnknownAffecteeFilterError(affectee_filter) from e
                 affectee_domain = self.__resolve_local_domain(affector_spec)
                 affectee_fits = affector_spec.item._fit,
                 return getter(self, affector_spec, affectee_domain, affectee_fits)
     */
  }
  
  func getProjectedAffectorStorages(affectorSpec: Any, targetItems: Any) {
    /*
     """Get places where passed projected affector spec should be stored.

     Raises:
         UnknownAffecteeFilterError: If modifier affectee filter type is not
             supported.
     """
     affectee_filter = affector_spec.modifier.affectee_filter
     # Modifier affects just targeted items directly
     if affectee_filter == ModAffecteeFilter.item:
         storages = []
         storage = self.__affectors_item_active
         for tgt_item in tgt_items:
             if tgt_item in self.__affectees:
                 key = tgt_item
                 storages.append((key, storage))
         return storages
     # Modifier affects multiple items via affectee filter
     else:
         try:
             getter = self.__affector_storages_getters[affectee_filter]
         except KeyError as e:
             raise UnknownAffecteeFilterError(affectee_filter) from e
         affectee_domain = ModDomain.ship
         affectee_fits = {i._fit for i in tgt_items if isinstance(i, Ship)}
         return getter(self, affector_spec, affectee_domain, affectee_fits)
     */
  }
  
  func getLocalAffectorStoragesSelf(affectorSpec: Any) {
    /*
     affectee_item = affector_spec.item
     if affectee_item in self.__affectees:
         key = affectee_item
         storage = self.__affectors_item_active
     else:
         key = affectee_item._fit
         storage = self.__affectors_item_awaiting
     return (key, storage),
     */
  }
  
  func getLocalAffectorStoragesCharacter(affectorSpec: Any) {
    /*
     affectee_fit = affector_spec.item._fit
     affectee_character = affectee_fit.character
     if affectee_character in self.__affectees:
         key = affectee_character
         storage = self.__affectors_item_active
     else:
         key = affectee_fit
         storage = self.__affectors_item_awaiting
     return (key, storage),
     */
  }
  
  func getLocalAffectorStoragesShip(affectorSpec: Any) {
    /*
     affectee_fit = affector_spec.item._fit
     affectee_ship = affectee_fit.ship
     if affectee_ship in self.__affectees:
         key = affectee_ship
         storage = self.__affectors_item_active
     else:
         key = affectee_fit
         storage = self.__affectors_item_awaiting
     return (key, storage),

     */
  }
  
  func getLocalAffectorStoragesOther(affectorSpec: Any) {
    /*
     # Affectors with 'other' modifiers are always stored in their special
     # place
     storages = [(affector_spec.item, self.__affectors_item_other)]
     # And all those which have valid affectee item are also stored in
     # storage for active direct affectors
     storage = self.__affectors_item_active
     for other_item in affector_spec.item._others:
         if other_item in self.__affectees:
             key = other_item
             storages.append((key, storage))
     return storages
     */
  }
  
  /*
   __local_affector_storages_getters = {
       ModDomain.self: __get_local_affector_storages_self,
       ModDomain.character: __get_local_affector_storages_character,
       ModDomain.ship: __get_local_affector_storages_ship,
       ModDomain.other: __get_local_affector_storages_other}
   */
  
  
  func getAffectorStoragesDomain(affectorSpec: Any?, affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    /*
     storages = []
     storage = self.__affectors_domain
     for affectee_fit in affectee_fits:
         key = (affectee_fit, affectee_domain)
         storages.append((key, storage))
     return storages
     */
  }
  
  func getAffectorStoragesDomainGroup(affectorSpec: Any?, affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    /*
     affectee_group_id = affector_spec.modifier.affectee_filter_extra_arg
     storages = []
     storage = self.__affectors_domain_group
     for affectee_fit in affectee_fits:
         key = (affectee_fit, affectee_domain, affectee_group_id)
         storages.append((key, storage))
     return storages
     */
  }
  
  func getAFfectorStoragesDomainSkillRequirement(affectorSpec: Any?, affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    /*
     affectee_srq_type_id = affector_spec.modifier.affectee_filter_extra_arg
     if affectee_srq_type_id == EosTypeId.current_self:
         affectee_srq_type_id = affector_spec.item._type_id
     storages = []
     storage = self.__affectors_domain_skillrq
     for affectee_fit in affectee_fits:
         key = (affectee_fit, affectee_domain, affectee_srq_type_id)
         storages.append((key, storage))
     return storages
     */
  }
  
  func getAffectorStoragesOwnerSkillRequirements(affectorSpec: Any?, affecteeDomain: AffecteeDomain, affecteeFits: Any) {
    /*
     affectee_srq_type_id = affector_spec.modifier.affectee_filter_extra_arg
     if affectee_srq_type_id == EosTypeId.current_self:
         affectee_srq_type_id = affector_spec.item._type_id
     storages = []
     storage = self.__affectors_owner_skillrq
     for affectee_fit in affectee_fits:
         key = (affectee_fit, affectee_srq_type_id)
         storages.append((key, storage))
     return storages
     */
  }
  
  /*
   __affector_storages_getters = {
       ModAffecteeFilter.domain:
           __get_affector_storages_domain,
       ModAffecteeFilter.domain_group:
           __get_affector_storages_domain_group,
       ModAffecteeFilter.domain_skillrq:
           __get_affector_storages_domain_skillrq,
       ModAffecteeFilter.owner_skillrq:
           __get_affector_storages_owner_skillrq}
   */
  
  func handleResolveDomain(affectorSpec: Any) {
    /*
     """Convert relative domain into absolute for local affector spec.

            Applicable only to en-masse modifications - that is, when modification
            affects multiple items in affectee domain.

            Raises:
                UnexpectedDomainError: If modifier affectee domain is not supported.
            """
            affector_item = affector_spec.item
            affectee_domain = affector_spec.modifier.affectee_domain
            if affectee_domain == ModDomain.self:
                if isinstance(affector_item, Ship):
                    return ModDomain.ship
                elif isinstance(affector_item, Character):
                    return ModDomain.character
                else:
                    raise UnexpectedDomainError(affectee_domain)
            # Just return untouched domain for all other valid cases. Valid cases
            # include 'globally' visible (within the fit scope) domains only. I.e.
            # if item on fit refers this affectee domain, it should always refer the
            # same affectee item regardless of position of source item.
            elif affectee_domain in (ModDomain.character, ModDomain.ship):
                return affectee_domain
            # Raise error if domain is invalid
            else:
                raise UnexpectedDomainError(affectee_domain)
     */
  }
  
  func handleAffectorSpecErrors(error: Any, affectorSpec: Any) {
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
