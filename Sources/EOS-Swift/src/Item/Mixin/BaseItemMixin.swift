//
//  BaseItemMixin.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//
//  https://github.com/pyfa-org/eos/blob/master/eos/item/mixin/base.py


/*
 Base class for all items.

 It provides all the data needed for attribute calculation to work properly.
 Not directly subclassed by items, but by other mixins (which implement
 concrete functionality over it).

 Args:
     type_id: Identifier of item type which should serve as base for this
         item.

 Cooperative methods:
     __init__
     _child_item_iter

 */

/*
 
 */

protocol BaseItemMixinProtocol: AnyObject, Hashable {
  var typeId: Int64 { get }
  var itemType: ItemType? { get set }
  //var container: String? { get set }
  var container: ItemContainerBase<BaseItemMixin>? { get set }
  
  var runningEffectIds: [Int64] { get set }
  var effectModeOverrides: String? { get set }
  var effectTargets: String? { get set }
  
  var state: State { get set }
  var fit: Fit? { get }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<BaseItemMixin>?
  
}

open class BaseItemMixin: BaseItemMixinProtocol, Hashable {
  var typeId: Int64
  var itemType: ItemType?
  var container: ItemContainerBase<BaseItemMixin>? = nil
  
  var runningEffectIds: [Int64] = []
  var effectModeOverrides: String? = nil
  var effectTargets: String? = nil
  var autocharges: String? = nil
  
  open var state: State
  
  var attributes: [Int64: Double] = [:]
  
  var fit: Fit? {
    self.container?.fit
  }
  
  init(typeId: Int64, state: State) {
    self.typeId = typeId
    self.itemType = nil
    self.container = nil
    self.effectModeOverrides = nil
    self.effectTargets = nil
    self.autocharges = nil
    self.state = state
  }
  
  public static func == (lhs: BaseItemMixin, rhs: BaseItemMixin) -> Bool {
    return lhs.typeId == rhs.typeId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<BaseItemMixin>? {
    if !skipAutoItems {
//      for item in self.autocharges!.lazy.map(\.value) {
//
//      }
    }
    return nil
  }
  
  func childItemIter(skipAutoitems: Bool = false) {
    if !skipAutoitems {
      // for item in self.autocharges.values():
      // yield item
    }
    
    /*
     # Try next in MRO
     try:
         child_item_iter = super()._child_item_iter
     except AttributeError:
         pass
     else:
         for item in child_item_iter(skip_autoitems=skip_autoitems):
             yield item
     */
  }
  

  
  /*
   @property
   @abstractmethod
   def state(self):
       ...
   */
  
  
  var typeAttributes: [Int64: Double] {
    return self.itemType?.attributes ?? [:]
  }
  
  var typeEffects: [Int64: Effect] {
    // return self.type.effects
    
    return [:]
  }
  
  var typeDefaultEffect: Any? {
    return self.itemType?.defaultEffect
  }
  
  var typeDefaultEffectId: Int64? {
    return self.itemType?.defaultEffect?.attributeId
  }
  
  var modifierDomain: Any? {
    nil
  }
  
  var ownerModifiable: Any? {
    nil
  }

  var solsysCarrier: Any? {
    nil
  }
  
  var others: Set<BaseItemMixin> {
    var otherItems: Set<BaseItemMixin> = []
    self.container
    if let container = self.container as? BaseItemMixin {
      otherItems.insert(container)
    }
    
    return otherItems
  }
  var isLoaded: Bool {
    if self.itemType == nil {
      return false
    } else {
      return true
    }
  }
  /*
   @property
   def _is_loaded(self):
       return False if self._type is None else True
   */
  /*
   
   
  def _unload(self):
          """Clear item's source-dependent data."""
          fit = self._fit
          # Send notifications about item being unloaded if it was loaded
          if fit is not None and self._is_loaded:
              msgs = MsgHelper.get_item_unloaded_msgs(self)
              fit._publish_bulk(msgs)
          self.attrs._clear()
          self._clear_autocharges()
          self._type = None
   
   */
  
  func load() {
    // get a getter
    
    for (effectId, effect) in self.typeEffects {
      let autoChargeTypeId = effect.getAutoChargeTypeId(item: <#T##BaseItemMixin#>)
    }
  }
  
  func unload() {
    let fit = self.fit
  
  }
}
/*
     @property
     def _others(self):
         other_items = set()
         container = self._container
         if isinstance(container, BaseItemMixin):
             other_items.add(container)
         other_items.update(self._child_item_iter())
         return other_items

     # Effect methods
     @property
     def effects(self):
         """Expose item's effects with item-specific data.

         Returns:
             Map in format {effect ID: (effect, effect run mode, effect run
             status)}.
         """
         effects = {}
         for effect_id, effect in self._type_effects.items():
             mode = self.get_effect_mode(effect_id)
             status = effect_id in self._running_effect_ids
             effects[effect_id] = EffectData(effect, mode, status)
         return effects

     def get_effect_mode(self, effect_id):
         """Get effect's run mode for this item."""
         if self.__effect_mode_overrides is None:
             return DEFAULT_EFFECT_MODE
         return self.__effect_mode_overrides.get(effect_id, DEFAULT_EFFECT_MODE)

     def set_effect_mode(self, effect_id, effect_mode):
         """Set effect's run mode for this item."""
         self._set_effects_modes({effect_id: effect_mode})

     def _set_effects_modes(self, effects_modes):
         """
         Set modes of multiple effects for this item.

         Args:
             effects_modes: Map in {effect ID: effect run mode} format.
         """
         for effect_id, effect_mode in effects_modes.items():
             # If new mode is default, then remove it from override map
             if effect_mode == DEFAULT_EFFECT_MODE:
                 # If override map is not initialized, we're not changing
                 # anything
                 if self.__effect_mode_overrides is None:
                     continue
                 # Try removing value from override map and do nothing if it
                 # fails. It means that default mode was requested for an effect
                 # for which getter will return default anyway
                 try:
                     del self.__effect_mode_overrides[effect_id]
                 except KeyError:
                     pass
             # If value is not default, initialize override map if necessary and
             # store value
             else:
                 if self.__effect_mode_overrides is None:
                     self.__effect_mode_overrides = {}
                 self.__effect_mode_overrides[effect_id] = effect_mode
         # After all the changes we did, check if there's any data in overrides
         # map, if there's no data, replace it with None to save memory
         if (
             self.__effect_mode_overrides is not None and
             len(self.__effect_mode_overrides) == 0
         ):
             self.__effect_mode_overrides = None
         fit = self._fit
         if fit is not None:
             msgs = MsgHelper.get_effects_status_update_msgs(self)
             if msgs:
                 fit._publish_bulk(msgs)

     # Autocharge methods
     @property
     def autocharges(self):
         """Returns map which contains charges, 'autoloaded' by effects.

         These charges will always be on item as long as item type defines them.
         """
         # Format {effect ID: charge item}
         return self.__autocharges or {}

     def _add_autocharge(self, effect_id, autocharge_type_id):
         # Using import here is ugly, but there's no good way to use subclass
         # within parent class. Other solution is to create method on fit and
         # call that method, but fit shouldn't really care about implementation
         # details of items too
         from eos.item import Autocharge
         if self.__autocharges is None:
             self.__autocharges = ItemDict(
                 self, Autocharge, container_override=self)
         self.__autocharges[effect_id] = Autocharge(autocharge_type_id)

     def _clear_autocharges(self):
         if self.__autocharges is not None:
             self.__autocharges.clear()
             self.__autocharges = None

     # Source-related methods
     @property
     def _is_loaded(self):
         return False if self._type is None else True

     def _load(self):
         """Load item's source-specific data."""
         fit = self._fit
         # Do nothing if we cannot reach cache handler
         try:
             getter = fit.solar_system.source.cache_handler.get_type
         except AttributeError:
             return
         # Do nothing if cache handler doesn't have item type we need
         try:
             self._type = getter(self._type_id)
         except TypeFetchError:
             return
         # If fetch is successful, launch bunch of messages
         if fit is not None:
             msgs = MsgHelper.get_item_loaded_msgs(self)
             fit._publish_bulk(msgs)
         # Add autocharges, if effects specify any
         for effect_id, effect in self._type_effects.items():
             autocharge_type_id = effect.get_autocharge_type_id(self)
             if autocharge_type_id is None:
                 continue
             self._add_autocharge(effect_id, autocharge_type_id)

     def _unload(self):
         """Clear item's source-dependent data."""
         fit = self._fit
         # Send notifications about item being unloaded if it was loaded
         if fit is not None and self._is_loaded:
             msgs = MsgHelper.get_item_unloaded_msgs(self)
             fit._publish_bulk(msgs)
         self.attrs._clear()
         self._clear_autocharges()
         self._type = None
 */


/*
 protocol BaseTargetableMixinProtocol {
   func getEffectsTarget() -> Any?
 }

 open class BaseTargetableMixin: BaseTargetableMixinProtocol {
   open func getEffectsTarget() -> Any? {
     nil
   }
 }
 */
