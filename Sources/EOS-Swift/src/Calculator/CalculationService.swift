//
//  CalculationService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

/*
 Service which supports attribute calculation.

 This class collects data about various items and relations between them, and
 via exposed methods which provice data about these connections helps
 attribute map to calculate modified attribute values.
 */

/*
 # Map which helps to normalize modifications
 NORMALIZATION_MAP = {
     ModOperator.pre_assign: lambda value: value, (value) -> { value }
     ModOperator.pre_mul: lambda value: value - 1, (value) -> { value - 1 }
     ModOperator.pre_div: lambda value: 1 / value - 1, (value) -> { 1 / value - 1 }
     ModOperator.mod_add: lambda value: value, (value) -> { value }
     ModOperator.mod_sub: lambda value: -value, (value) -> { value * -1 }
     ModOperator.post_mul: lambda value: value - 1, (value) -> { value - 1 }
     ModOperator.post_mul_immune: lambda value: value - 1, (value) -> { value - 1 }
     ModOperator.post_div: lambda value: 1 / value - 1, (value) -> { 1 / value - 1 }
     ModOperator.post_percent: lambda value: value / 100, (value) -> { value / 100 }
     ModOperator.post_assign: lambda value: value}, (value) -> { value }
 
   func normalize(modOperator: ModOperator, value: Double) -> Double {
   switch modOperator {
   case .pre_assign: return value
   case .pre_mul: return value - 1
   case .pre_div: return 1 / value - 1
   case .mod_add: return value
   case .mod_sub: return -value
   case .post_mul: return value - 1
   case .post_div: return 1 / value - 1
   case .post_percent: return value / 100
   case .post_assign: return value
   default: return value
   }
   }

 */



//self.operator, value, self.aggregate_mode, self.aggregate_key
struct GetModResponse {
  var modOperator: ModOperator?
  let modValue: Double?
  let aggregateMode: ModAggregateMode?
  let aggregateKey: AnyHashable?
}

/*
 _handler_map = {
     FleetFitAdded: _handle_fleet_fit_added,
     FleetFitRemoved: _handle_fleet_fit_removed,
     ItemLoaded: _handle_item_loaded,
     ItemUnloaded: _handle_item_unloaded,
     EffectsStarted: _handle_effects_started,
     EffectsStopped: _handle_effects_stopped,
     EffectApplied: _handle_effect_applied,
     EffectUnapplied: _handle_effect_unapplied,
     AttrsValueChanged: _revise_regular_attr_dependents}
 */

class CalculationService: BaseSubscriber, BaseSubscriberProtocol {
  static func == (lhs: CalculationService, rhs: CalculationService) -> Bool {
    false
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  var handlerMap: [MessageTypeEnum: CallbackHandler]
  
//  var handlerMap: [MessageTypeEnum: CallbackHandler] = [
//    .FleetFitAdded: handleFleetFitAdded,
//  ]

  weak var solarSystem: SolarSystem?
  var affections: AffectionRegister? = nil  // AffectionRegister
  var projections: ProjectionRegister? = nil  // ProjectionRegister
  // Format: {projector: {modifiers}}
  var warfareBuffs = KeyedStorage()

  // Container with affector specs which will receive messages
  // Format: {message type: set(affector specs)}
  var subscribedAffectors = KeyedStorage()

  init(solarSystem: SolarSystem) {
    self.solarSystem = solarSystem
    self.handlerMap = [:]
    
    self.handlerMap = [
      .FleetFitAdded: { }
    ]
  }

  func notify(_ message: any Message) {

  }

  /// Get modifications of affectee attribute on affectee item.
  /// - Parameters:
  ///   - affecteeItem: Item, for which we're getting modifications.
  ///   - affecteeAttributeId: Affectee attribute ID; only modifications which influence attribute with this ID will be returned.
  func getModifications(
    affecteeItem: any BaseItemMixinProtocol,
    affecteeAttributeId: AttrId
  ) -> [ModificationData] {
    var returnValues: [ModificationData] = []

    /*
     this function returns an object of
     mod_op, mod_value, resist_value,
     mod_aggregate_mode, mod_aggregate_key,
     affector_item*/
    /*
     # Use list because we can have multiple tuples with the same values
             # as valid configuration
             mods = []
             for affector_spec in self.__affections.get_affector_specs(
                 affectee_item
             ):
                 affector_modifier = affector_spec.modifier
                 affector_item = affector_spec.item
                 if affector_modifier.affectee_attr_id != affectee_attr_id:
                     continue
                 try:
                     mod_op, mod_value, mod_aggregate_mode, mod_aggregate_key = (
                         affector_modifier.get_modification(affector_item))
                 # Do nothing here - errors should be logged in modification
                 # getter or even earlier
                 except ModificationCalculationError:
                     continue
                 # Get resistance value
                 resist_attr_id = affector_spec.effect.resist_attr_id
                 carrier_item = affectee_item._solsys_carrier
                 if resist_attr_id and carrier_item is not None:
                     try:
                         resist_value = carrier_item.attrs[resist_attr_id]
                     except KeyError:
                         resist_value = 1
                 else:
                     resist_value = 1
                 mods.append((
                     mod_op, mod_value, resist_value,
                     mod_aggregate_mode, mod_aggregate_key,
                     affector_item))
             return mods
     */

    guard let affections = self.affections else { return [] }

    guard
      let affectorSet = affections.getAffectorSpecs(affecteeItem: affecteeItem)
    else {
      print("No affectorSpecs")
      return []
    }

    let affectorSpecs = affectorSet.compactMap { $0 as? AffectorSpec }
    guard affectorSpecs.count == affectorSet.count else {
      print(
        "mismatch affector count \(affectorSpecs.count) vs \(affectorSet.count)"
      )
      return []
    }

    for affectorSpec in affectorSpecs {
      let affectorModifier = affectorSpec.modifier
      let affectorItem = affectorSpec.itemType

      guard affectorModifier.affecteeAtributeId == affecteeAttributeId else {
        continue
      }
      let modifier = affectorModifier.getModification(
        affectorItem: affectorItem
      )
    
      // get resistance value
      let resistAttrId = affectorSpec.effect.resistanceAttributeID
      let carrierItem = affecteeItem.solsysCarrier
      let resistValue: Double
      
      if let resistAttrId, let carrierItem,
        let resistAttr = AttrId(rawValue: resistAttrId)
      {
        resistValue = carrierItem.attributes?[resistAttr] ?? 1
      } else {
        resistValue = 1
      }

      returnValues.append(
        ModificationData(
          modOperator: modifier?.modOperator,
          modValue: modifier?.modValue ?? 0,
          resistValue: resistValue,
          attributeValue: nil,
          aggregateMode: modifier?.aggregateMode,
          aggregateKey: modifier?.aggregateKey,
          affectorItem: affectorItem
        )
      )

    }

    return returnValues
  }
  
  func handleFitAdded(fit: Fit) {
    fit.subscribe(subscriber: self, for: Array(self.handlerMap.keys))
  }
  
  func handleFitRemoved(fit: Fit) {
    fit.unsubscribe(subscriber: self, from: Array(self.handlerMap.keys))
  }
  
  /// Handle item changes which are significant for calculator
  func handleFleetFitAdded(message: any Message) {
    /*
     fits_effect_applications = {}
     for projector in self.__projections.get_projectors():
         if not isinstance(projector.effect, WarfareBuffEffect):
             continue
         projector_fit = projector.item._fit
         # Affect this fit by buffs existing in fleet
         if (
             msg.fit.ship is not None and
             projector_fit.fleet is msg.fit.fleet
         ):
             fits_effect_applications.setdefault(
                 projector_fit, []).append(
                 (projector, [msg.fit.ship]))
         # Affect other fits by buffs from this fit
         if projector_fit is msg.fit:
             for fit in msg.fit.fleet.fits:
                 if fit is msg.fit:
                     continue
                 fits_effect_applications.setdefault(
                     projector_fit, []).append(
                     (projector, [fit.ship]))
     # Apply warfare buffs
     if fits_effect_applications:
         for fit, effect_applications in fits_effect_applications.items():
             msgs = []
             for projector, tgt_items in effect_applications:
                 msgs.append(EffectApplied(
                     projector.item, projector.effect.id, tgt_items))
             fit._publish_bulk(msgs)
     */
  }
  
  func handleFleetFitRemoved(message: any Message) {
    /*
     fits_effect_unapplications = {}
     for projector in self.__projections.get_projectors():
         if not isinstance(projector.effect, WarfareBuffEffect):
             continue
         projector_fit = projector.item._fit
         # Unaffect this fit by buffs existing in fleet
         if (
             msg.fit.ship is not None and
             projector_fit.fleet is msg.fit.fleet
         ):
             fits_effect_unapplications.setdefault(
                 projector_fit, []).append(
                 (projector, [msg.fit.ship]))
         # Unaffect other fits by buffs from this fit
         if projector_fit is msg.fit:
             for fit in msg.fit.fleet.fits:
                 if fit is msg.fit:
                     continue
                 fits_effect_unapplications.setdefault(
                     projector_fit, []).append(
                     (projector, [fit.ship]))
     # Unapply warfare buffs
     if fits_effect_unapplications:
         for fit, effect_unapplications in (
             fits_effect_unapplications.items()
         ):
             msgs = []
             for projector, tgt_items in effect_unapplications:
                 msgs.append(EffectUnapplied(
                     projector.item, projector.effect.id, tgt_items))
             fit._publish_bulk(msgs)
     */
  }
  
  func handleItemLoaded(message: any Message) {
    /*
     item = msg.item
             self.__affections.register_affectee_item(item)
             if isinstance(item, SolarSystemItemMixin):
                 self.__projections.register_solsys_item(item)
     */
  }
  
  func handleItemUnloaded(message: any Message) {
    /*
     item = msg.item
             self.__affections.unregister_affectee_item(item)
             if isinstance(item, SolarSystemItemMixin):
                 self.__projections.unregister_solsys_item(item)
     */
  }
  
  func handleEffectsStarted(message: any Message) {
    /*
     item = msg.item
             effect_ids = msg.effect_ids
             attr_changes = {}
             for affector_spec in self.__generate_local_affector_specs(
                 item, effect_ids
             ):
                 # Register the affector spec
                 if isinstance(affector_spec.modifier, BasePythonModifier):
                     self.__subscribe_python_affector_spec(msg.fit, affector_spec)
                 self.__affections.register_local_affector_spec(affector_spec)
                 # Clear values of attributes dependent on the affector spec
                 for affectee_item in self.__affections.get_local_affectee_items(
                     affector_spec
                 ):
                     attr_id = affector_spec.modifier.affectee_attr_id
                     if affectee_item.attrs._force_recalc(attr_id):
                         attr_ids = attr_changes.setdefault(affectee_item, set())
                         attr_ids.add(attr_id)
             # Register projectors
             for projector in self.__generate_projectors(item, effect_ids):
                 self.__projections.register_projector(projector)
             # Register warfare buffs
             effect_applications = []
             item_fleet = msg.fit.fleet
             for effect_id in effect_ids:
                 effect = item._type_effects[effect_id]
                 if not isinstance(effect, WarfareBuffEffect):
                     continue
                 projector = Projector(item, effect)
                 for buff_id_attr_id in WARFARE_BUFF_ATTRS:
                     try:
                         buff_id = item.attrs[buff_id_attr_id]
                     except KeyError:
                         continue
                     getter = (
                         self.__solar_system.source.cache_handler.get_buff_templates)
                     try:
                         buff_templates = getter(buff_id)
                     except BuffTemplatesFetchError:
                         continue
                     affector_attr_id = WARFARE_BUFF_ATTRS[buff_id_attr_id]
                     if not buff_templates:
                         continue
                     for buff_template in buff_templates:
                         modifier = DogmaModifier._make_from_buff_template(
                             buff_template, affector_attr_id)
                         affector_spec = AffectorSpec(item, effect, modifier)
                         self.__warfare_buffs.add_data_entry(
                             projector, affector_spec)
                     tgt_ships = []
                     for tgt_fit in self.__solar_system.fits:
                         if (
                             tgt_fit is msg.fit or
                             (item_fleet is not None and tgt_fit.fleet is item_fleet)
                         ):
                             tgt_ship = tgt_fit.ship
                             if tgt_ship is not None:
                                 tgt_ships.append(tgt_ship)
                     effect_applications.append((projector, tgt_ships))
             if attr_changes:
                 self.__publish_attr_changes(attr_changes)
             # Apply warfare buffs
             if effect_applications:
                 msgs = []
                 for projector, tgt_items in effect_applications:
                     msgs.append(EffectApplied(
                         projector.item, projector.effect.id, tgt_items))
                 msg.fit._publish_bulk(msgs)
     */
  }
  
  func handleEffectsStopped(message: any Message) {
    /*
     # Get info on warfare buffs
             effect_unapplications = []
             for projector in self.__generate_projectors(msg.item, msg.effect_ids):
                 if projector not in self.__warfare_buffs:
                     continue
                 tgt_ships = self.__projections.get_projector_tgts(projector)
                 effect_unapplications.append((projector, tgt_ships))
             # Unapply and unregister warfare buffs
             if effect_unapplications:
                 msgs = []
                 for projector, tgt_items in effect_unapplications:
                     msgs.append(EffectUnapplied(
                         projector.item, projector.effect.id, tgt_items))
                 msg.fit._publish_bulk(msgs)
                 for projector, _ in effect_unapplications:
                     del self.__warfare_buffs[projector]
             attr_changes = {}
             # Remove values of affectee attributes
             for affector_spec in self.__generate_local_affector_specs(
                 msg.item, msg.effect_ids
             ):
                 # Clear values of attributes dependent on the affector spec
                 for affectee_item in self.__affections.get_local_affectee_items(
                     affector_spec
                 ):
                     attr_id = affector_spec.modifier.affectee_attr_id
                     if affectee_item.attrs._force_recalc(attr_id):
                         attr_ids = attr_changes.setdefault(affectee_item, set())
                         attr_ids.add(attr_id)
                 # Unregister the affector spec
                 self.__affections.unregister_local_affector_spec(affector_spec)
                 if isinstance(affector_spec.modifier, BasePythonModifier):
                     self.__unsubscribe_python_affector_spec(msg.fit, affector_spec)
             # Unregister projectors
             for projector in self.__generate_projectors(msg.item, msg.effect_ids):
                 self.__projections.unregister_projector(projector)
             if attr_changes:
                 self.__publish_attr_changes(attr_changes)
     */
  }
  
  func handleEffectsApplied(message: any Message) {
    /*
     attr_changes = {}
     for affector_spec in self.__generate_projected_affectors(
         msg.item, (msg.effect_id,)
     ):
         # Register the affector spec
         self.__affections.register_projected_affector_spec(
             affector_spec, msg.tgt_items)
         # Clear values of attributes dependent on the affector spec
         for affectee_item in self.__affections.get_projected_affectee_items(
             affector_spec, msg.tgt_items
         ):
             attr_id = affector_spec.modifier.affectee_attr_id
             if affectee_item.attrs._force_recalc(attr_id):
                 attr_ids = attr_changes.setdefault(affectee_item, set())
                 attr_ids.add(attr_id)
     # Apply projector
     for projector in self.__generate_projectors(msg.item, (msg.effect_id,)):
         self.__projections.apply_projector(projector, msg.tgt_items)
     if attr_changes:
         self.__publish_attr_changes(attr_changes)
     */
  }
  
  func handleEffectsUnapplied(message: any Message) {
    /*
     for affector_spec in self.__generate_projected_affectors(
         msg.item, (msg.effect_id,)
     ):
         # Clear values of attributes dependent on the affector spec
         for affectee_item in self.__affections.get_projected_affectee_items(
             affector_spec, msg.tgt_items
         ):
             attr_id = affector_spec.modifier.affectee_attr_id
             if affectee_item.attrs._force_recalc(attr_id):
                 attr_ids = attr_changes.setdefault(affectee_item, set())
                 attr_ids.add(attr_id)
         # Unregister the affector spec
         self.__affections.unregister_projected_affector(
             affector_spec, msg.tgt_items)
     # Un-apply projector
     for projector in self.__generate_projectors(msg.item, (msg.effect_id,)):
         self.__projections.unapply_projector(projector, msg.tgt_items)
     if attr_changes:
         self.__publish_attr_changes(attr_changes)
     */
  }

  
  /// Methods to clear calculated child attributes when parent attributes change
  func reviseRegularAttrDependents(message: any Message) {
    /*
     Remove calculated attribute values which rely on passed attribute.

             Removing them allows to recalculate updated value. Here we process all
             regular dependents, which include dependencies specified via capped
             attribute map and via affector specs with dogma modifiers. Affector
             specs with python modifiers are processed separately.
     */
    
    /*
     affections = self.__affections
             projections = self.__projections
             effect_unapplications = []
             # Unapply warfare buffs
             for item, attr_ids in msg.attr_changes.items():
                 for effect in item._type_effects.values():
                     projector = Projector(item, effect)
                     if projector not in self.__warfare_buffs:
                         continue
                     if not attr_ids.intersection(WARFARE_BUFF_ATTRS):
                         continue
                     tgt_items = self.__projections.get_projector_tgts(projector)
                     effect_unapplications.append((projector, tgt_items))
             msgs = []
             for projector, tgt_items in effect_unapplications:
                 msgs.append(EffectUnapplied(
                     projector.item, projector.effect.id, tgt_items))
             msg.fit._publish_bulk(msgs)
             attr_changes = {}
             for item, attr_ids in msg.attr_changes.items():
                 # Remove values of affectee attributes capped by the changing
                 # attribute
                 for attr_id in attr_ids:
                     for capped_attr_id in item.attrs._cap_map.get(attr_id, ()):
                         if item.attrs._force_recalc(capped_attr_id):
                             attr_changes.setdefault(item, set()).add(capped_attr_id)
                 # Force attribute recalculation when local affector spec
                 # modification changes
                 for affector_spec in self.__generate_local_affector_specs(
                     item, item._running_effect_ids
                 ):
                     affector_modifier = affector_spec.modifier
                     # Only dogma modifiers have source attribute specified, python
                     # modifiers are processed separately
                     if (
                         not isinstance(affector_modifier, DogmaModifier) or
                         affector_modifier.affector_attr_id not in attr_ids
                     ):
                         continue
                     # Remove values
                     for affectee_item in affections.get_local_affectee_items(
                         affector_spec
                     ):
                         attr_id = affector_modifier.affectee_attr_id
                         if affectee_item.attrs._force_recalc(attr_id):
                             attr_changes.setdefault(affectee_item, set()).add(
                                 attr_id)
                 # Force attribute recalculation when projected affector spec
                 # modification changes
                 for projector in self.__generate_projectors(
                     item, item._running_effect_ids
                 ):
                     tgt_items = projections.get_projector_tgts(projector)
                     # When projector doesn't target any items, then we do not need
                     # to clean anything
                     if not tgt_items:
                         continue
                     for affector_spec in self.__generate_projected_affectors(
                         item, (projector.effect.id,)
                     ):
                         affector_modifier = affector_spec.modifier
                         # Only dogma modifiers have source attribute specified,
                         # python modifiers are processed separately
                         if (
                             not isinstance(affector_modifier, DogmaModifier) or
                             affector_modifier.affector_attr_id not in attr_ids
                         ):
                             continue
                         for affectee_item in (
                             affections.get_projected_affectee_items(
                                 affector_spec, tgt_items)
                         ):
                             attr_id = affector_modifier.affectee_attr_id
                             if affectee_item.attrs._force_recalc(attr_id):
                                 attr_changes.setdefault(affectee_item, set()).add(
                                     attr_id)
                 # Force attribute recalculation if changed attribute defines
                 # resistance to some effect
                 for projector in projections.get_tgt_projectors(item):
                     effect = projector.effect
                     if effect.resist_attr_id not in attr_ids:
                         continue
                     tgt_items = projections.get_projector_tgts(projector)
                     for affector_spec in self.__generate_projected_affectors(
                         projector.item, (effect.id,)
                     ):
                         for affectee_item in (
                             affections.get_projected_affectee_items(
                                 affector_spec, tgt_items)
                         ):
                             attr_id = affector_spec.modifier.affectee_attr_id
                             if affectee_item.attrs._force_recalc(attr_id):
                                 attr_changes.setdefault(affectee_item, set()).add(
                                     attr_id)
             # Unregister warfare buffs only after composing list of attributes we
             # should update
             for projector, tgt_items in effect_unapplications:
                 del self.__warfare_buffs[projector]
             if attr_changes:
                 self.__publish_attr_changes(attr_changes)
             # Register warfare buffs
             effect_applications = []
             for item, attr_ids in msg.attr_changes.items():
                 if not attr_ids.intersection(WARFARE_BUFF_ATTRS):
                     continue
                 item_fleet = item._fit.fleet
                 for effect_id in item._running_effect_ids:
                     effect = item._type_effects[effect_id]
                     if not isinstance(effect, WarfareBuffEffect):
                         continue
                     projector = Projector(item, effect)
                     for buff_id_attr_id in WARFARE_BUFF_ATTRS:
                         try:
                             buff_id = item.attrs[buff_id_attr_id]
                         except KeyError:
                             continue
                         getter = (
                             self.__solar_system.source.
                             cache_handler.get_buff_templates)
                         try:
                             buff_templates = getter(buff_id)
                         except BuffTemplatesFetchError:
                             continue
                         affector_attr_id = WARFARE_BUFF_ATTRS[buff_id_attr_id]
                         if not buff_templates:
                             continue
                         for buff_template in buff_templates:
                             modifier = DogmaModifier._make_from_buff_template(
                                 buff_template, affector_attr_id)
                             affector_spec = AffectorSpec(item, effect, modifier)
                             self.__warfare_buffs.add_data_entry(
                                 projector, affector_spec)
                         tgt_ships = []
                         for tgt_fit in self.__solar_system.fits:
                             if (
                                 tgt_fit is msg.fit or (
                                     item_fleet is not None and
                                     tgt_fit.fleet is item_fleet)
                             ):
                                 tgt_ship = tgt_fit.ship
                                 if tgt_ship is not None:
                                     tgt_ships.append(tgt_ship)
                         effect_applications.append((projector, tgt_ships))
             if attr_changes:
                 self.__publish_attr_changes(attr_changes)
             # Apply warfare buffs
             if effect_applications:
                 msgs = []
                 for projector, tgt_items in effect_applications:
                     msgs.append(EffectApplied(
                         projector.item, projector.effect.id, tgt_items))
                 msg.fit._publish_bulk(msgs)
     */
  }
  
  func revisePythonAttrDependents(message: any Message) {
    /*
     Remove calculated attribute values when necessary.

            Here we go through python modifiers, deliver to them message, and if,
            based on contents of the message, they decide that calculated values
            should be removed, we remove values which depend on such modifiers.
            
     */
    
    /*
     attr_changes = {}
             # If there's no subscribed affector specs for received message type, do
             # nothing
             msg_type = type(msg)
             if msg_type not in self.__subscribed_affectors:
                 return
             # Otherwise, ask modifier if value of attribute it calculates may
             # change, and force recalculation if answer is yes
             for affector_spec in self.__subscribed_affectors[msg_type]:
                 if not affector_spec.modifier.revise_modification(
                     msg, affector_spec.item
                 ):
                     continue
                 for affectee_item in self.__affections.get_local_affectee_items(
                     affector_spec
                 ):
                     attr_id = affector_spec.modifier.affectee_attr_id
                     if affectee_item.attrs._force_recalc(attr_id):
                         attr_ids = attr_changes.setdefault(affectee_item, set())
                         attr_ids.add(attr_id)
             if attr_changes:
                 self.__publish_attr_changes(attr_changes)

         # Message routing
         _handler_map = {
             FleetFitAdded: _handle_fleet_fit_added,
             FleetFitRemoved: _handle_fleet_fit_removed,
             ItemLoaded: _handle_item_loaded,
             ItemUnloaded: _handle_item_unloaded,
             EffectsStarted: _handle_effects_started,
             EffectsStopped: _handle_effects_stopped,
             EffectApplied: _handle_effect_applied,
             EffectUnapplied: _handle_effect_unapplied,
             AttrsValueChanged: _revise_regular_attr_dependents}
     */
  }
  
  func notify(message: any Message) {
    
    /*
     BaseSubscriber._notify(self, msg)
             # Relay all messages to python modifiers, as in case of python modifiers
             # any message may result in deleting dependent attributes
             self._revise_python_attr_dependents(msg)
     */
  }
  
  /// Get local affector specs for passed item and effects.
  func generateLocalAffectorSpecs(item: any BaseItemMixinProtocol, effectIds: [EffectId]) -> Set<AffectorSpec> {
    var affectorSpecs: Set<AffectorSpec> = []
    /*
     affector_specs = set()
             item_effects = item._type_effects
             for effect_id in effect_ids:
                 effect = item_effects[effect_id]
                 for modifier in effect.local_modifiers:
                     affector_spec = AffectorSpec(item, effect, modifier)
                     affector_specs.add(affector_spec)
     */
    return affectorSpecs
  }
  
  /// Get projected affector specs for passed item and effects.
  func generateProjectedAffectorSpecs(item: any BaseItemMixinProtocol, effectIds: [EffectId]) -> Set<AffectorSpec> {
    var affectorSpecs: Set<AffectorSpec> = []
    let itemEffects = item.typeEffects
    
    for effectId in effectIds {
      guard let effect = itemEffects[effectId] else {
        continue
      }
      
      let projector = Projector(item: item as! BaseItemMixin, effect: effect)
      if let existing = self.warfareBuffs.dictionary[projector] as? AffectorSpec {
        affectorSpecs.update(with: existing)
      }
      
      for modifier in effect.projectedModifiers() {
        let affectorSpec = AffectorSpec(modifier: modifier, effect: effect, itemType: item)
        affectorSpecs.insert(affectorSpec)
      }
    }
    /*
     affector_specs = set()
     item_effects = item._type_effects
     for effect_id in effect_ids:
         effect = item_effects[effect_id]
         projector = Projector(item, effect)
         if projector in self.__warfare_buffs:
             affector_specs.update(self.__warfare_buffs[projector])
         for modifier in effect.projected_modifiers:
             affector_spec = AffectorSpec(item, effect, modifier)
             affector_specs.add(affector_spec)
     */
    return affectorSpecs
  }
  
  /// Subscribe affector spec with python modifier.
  func subscribePythonAffectorSpec(fit: Fit, affectorSpec: AffectorSpec) {
    /*
     to_subscribe = set()
             for msg_type in affector_spec.modifier.revise_msg_types:
                 # Subscribe service to new message type only if there's no such
                 # subscription yet
                 if (
                     msg_type not in self._handler_map and
                     msg_type not in self.__subscribed_affectors
                 ):
                     to_subscribe.add(msg_type)
                 # Add affector spec to subscriber map to let it receive messages
                 self.__subscribed_affectors.add_data_entry(msg_type, affector_spec)
             if to_subscribe:
                 fit._subscribe(self, to_subscribe)
     */
  }
  
  /// unsubscribe affector spec with python modifier.
  func unsubscribePythonAffectorSpec(fit: Fit, affectorSpec: AffectorSpec) {
    /*
     to_ubsubscribe = set()
             for msg_type in affector_spec.modifier.revise_msg_types:
                 # Make sure affector spec will not receive messages anymore
                 self.__subscribed_affectors.rm_data_entry(msg_type, affector_spec)
                 # Unsubscribe service from message type if there're no recipients
                 # anymore
                 if (
                     msg_type not in self._handler_map and
                     msg_type not in self.__subscribed_affectors
                 ):
                     to_ubsubscribe.add(msg_type)
             if to_ubsubscribe:
                 fit._unsubscribe(self, to_ubsubscribe)
     */
  }
  
  func generateProjectors(item: any BaseItemMixinProtocol, effectIds: [EffectId]) -> Set<Projector> {
    var projectors: Set<Projector> = []
    let itemEffects = item.typeEffects
    
    for effectId in effectIds {
      guard let effect = itemEffects[effectId], let categoryID = effect.categoryID,
            categoryID == .target || (effect is WarfareBuffEffect)
      else {
        continue
      }
      
      let projector = Projector(item: item as! BaseItemMixin, effect: effect)
      projectors.insert(projector)
    }
    
    return projectors
  }
  
  func publishAttrChanges(attrChanges: Any?) {
    /*
     # Format: {fit: {item: {attr_ids}}}
     fit_changes_regular = {}
     # Format: {fit: {item: {attr_ids}}}
     fit_changes_masked = {}
     for item, attr_ids in attr_changes.items():
         item_fit = item._fit
         item_attr_overrides = item.attrs._override_callbacks
         item_changes_regular = attr_ids.difference(item_attr_overrides)
         item_changes_masked = attr_ids.intersection(item_attr_overrides)
         if item_changes_regular:
             fit_changes_regular.setdefault(
                 item_fit, {})[item] = item_changes_regular
         if item_changes_masked:
             fit_changes_masked.setdefault(
                 item_fit, {})[item] = item_changes_masked
     # Format: {fit, [messages]}
     fits_msgs = {}
     for fit, attr_changes in fit_changes_regular.items():
         msg = AttrsValueChanged(attr_changes)
         fits_msgs.setdefault(fit, []).append(msg)
     for fit, attr_changes in fit_changes_masked.items():
         msg = AttrsValueChangedMasked(attr_changes)
         fits_msgs.setdefault(fit, []).append(msg)
     for fit, msgs in fits_msgs.items():
         fit._publish_bulk(msgs)
     */
  }
}
