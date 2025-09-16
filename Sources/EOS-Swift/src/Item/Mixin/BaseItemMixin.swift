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
  var container: (any ItemContainerBaseProtocol)? { get set }
  
  var runningEffectIds: Set<EffectId> { get set }
  var effectModeOverrides: [EffectId: EffectMode]? { get set }
  var effectTargets: String? { get set }
  var attributes: [AttrId: Double] { get set } // will be a custom dictionary type
  
  var _state: State { get set }
  var modifierDomain: ModDomain? { get set }
  var ownerModifiable: Bool { get set }
  var solsysCarrier: Ship? { get set }
  var fit: Fit? { get }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>?
  
  var isLoaded: Bool { get }
  func load()
  func unload()
  
}

extension BaseItemMixinProtocol {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.typeId == rhs.typeId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>? {
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
  
  
  var typeAttributes: [AttrId: Double] {
    return self.itemType?.attributes ?? [:]
  }
  
  var typeEffects: [EffectId: Effect] {
    // return self.type.effects
    self.itemType?.effects ?? [:]
  }
  
  var typeDefaultEffect: Any? {
    return self.itemType?.defaultEffect
  }
  
  var typeDefaultEffectId: Int64? {
    return self.itemType?.defaultEffect?.effectId
  }
  
  var others: Set<BaseItemMixin> {
    var otherItems: Set<BaseItemMixin> = []
    
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


  func load() {
    // get a getter
    for (effectId, effect) in self.typeEffects {
      //let autoChargeTypeId = effect.getAutoChargeTypeId(item: <#T##BaseItemMixin#>)
    }
  }
  
  func unload() {
    let fit = self.fit
  
  }
  
  var effects: [EffectId: EffectData] {
    var effects: [EffectId: EffectData] = [:]
    
    for (key, value) in self.typeEffects {
      let effectMode = self.getEffectMode(effectId: key)
      let status = self.runningEffectIds.contains(key)
      effects[key] = EffectData(effect: value, mode: effectMode, status: status)
    }
    return effects
  }
  
  func getEffectMode(effectId: EffectId) -> EffectMode {
    if self.effectModeOverrides == nil {
      return .full_compliance
    }
    
    guard let effectModeOverrides else {
      return .full_compliance
    }
    
    return effectModeOverrides[effectId, default: .full_compliance]
  }
  
  func setEffectMode(effectId: EffectId, effectMode: EffectMode) {
    self.setEffectsModes(effectsModes: [effectId: effectMode])
  }
  
//  def _set_effects_modes(self, effects_modes):
  func setEffectsModes(effectsModes: [EffectId: EffectMode]) {
    for (effectId, effectMode) in effectsModes {
      if effectMode == .full_compliance {
        guard let effectModeOverrides else {
          continue
        }
        self.effectModeOverrides?[effectId] = nil
      } else {
        var effectModeOverrides = self.effectModeOverrides ?? [:]
        effectModeOverrides[effectId] = effectMode
        self.effectModeOverrides = effectModeOverrides
      }
    }
    
    if self.effectModeOverrides?.isEmpty == true {
      self.effectModeOverrides = nil
    }
    
    if let fit = self.fit {
      // msgs = MsgHelper.get_effects_status_update_msgs(self)
      // fit.publish_bulk(msgs)
    }
    
  }
  
  /*
   # Autocharge methods
   @property
   def autocharges(self):
       """Returns map which contains charges, 'autoloaded' by effects.

       These charges will always be on item as long as item type defines them.
       """
       # Format {effect ID: charge item}
       return self.__autocharges or {}
   */
  
  //var autocharges: [Int64: AutoCharge] = [:]
  
    /*
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
     */
  
  func addAutoCharge(effectId: Int64, autoChargeTypeId: Int64) {
    
  }
}

extension BaseItemMixinProtocol {
  
}

open class BaseItemMixin: BaseItemMixinProtocol, Hashable {
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<BaseItemMixin>? {
    nil
  }
  
  public var userModifiable: Bool
  
  public var typeId: Int64
  public var itemType: ItemType?
  weak var container: (any ItemContainerBaseProtocol)? = nil
  
  var runningEffectIds: Set<EffectId> = []
  var effectModeOverrides: [EffectId: EffectMode]? = nil
  public var effectTargets: String? = nil
  
  open var _state: State
  
  public var attributes: [AttrId: Double] = [:]
  
  var fit: Fit? {
    if let container = self.container as? MaybeFitHaving {
      return container.fit
    }
    return nil
  }
  
  
  
  init(typeId: Int64, state: State) {
    self.typeId = typeId
    self.itemType = nil
    self.container = nil
    self.effectModeOverrides = nil
    self.effectTargets = nil
    self.autocharges = [:]
    self._state = state
    
    self.modifierDomain = .ship
    self.ownerModifiable = false
    self.solsysCarrier = nil
    self.userModifiable = true
  }
  
  public static func == (lhs: BaseItemMixin, rhs: BaseItemMixin) -> Bool {
    return lhs.typeId == rhs.typeId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>? {
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
  
  
  var typeAttributes: [AttrId: Double] {
    return self.itemType?.attributes ?? [:]
  }
  
  var typeEffects: [EffectId: Effect] {
    // return self.type.effects
    
    return [:]
  }
  
  var typeDefaultEffect: Any? {
    return self.itemType?.defaultEffect
  }
  
  var typeDefaultEffectId: Int64? {
    return self.itemType?.defaultEffect?.effectId
  }
  
  public var modifierDomain: ModDomain?
  
  public var ownerModifiable: Bool

  var solsysCarrier: Ship?
  
  var others: Set<BaseItemMixin> {
    var otherItems: Set<BaseItemMixin> = []
    
    if let container = self.container as? BaseItemMixin {
      otherItems.insert(container)
    }
    
    return otherItems
  }
  
  public var isLoaded: Bool {
    if self.itemType == nil {
      return false
    } else {
      return true
    }
  }


  public func load() {
    // get a getter
    for (effectId, effect) in self.typeEffects {
      //let autoChargeTypeId = effect.getAutoChargeTypeId(item: <#T##BaseItemMixin#>)
    }
  }
  
  public func unload() {
    let fit = self.fit
  
  }
  
  var effects: [EffectId: EffectData] {
    var effects: [EffectId: EffectData] = [:]
    
    for (key, value) in self.typeEffects {
      let effectMode = self.getEffectMode(effectId: key)
      let status = self.runningEffectIds.contains(key)
      effects[key] = EffectData(effect: value, mode: effectMode, status: status)
    }
    return effects
  }
  
  func getEffectMode(effectId: EffectId) -> EffectMode {
    if self.effectModeOverrides == nil {
      return .full_compliance
    }
    
    guard let effectModeOverrides else {
      return .full_compliance
    }
    
    return effectModeOverrides[effectId, default: .full_compliance]
  }
  
  func setEffectMode(effectId: EffectId, effectMode: EffectMode) {
    self.setEffectsModes(effectsModes: [effectId: effectMode])
  }
  
//  def _set_effects_modes(self, effects_modes):
  func setEffectsModes(effectsModes: [EffectId: EffectMode]) {
    for (effectId, effectMode) in effectsModes {
      if effectMode == .full_compliance {
        guard let effectModeOverrides else {
          continue
        }
        self.effectModeOverrides?[effectId] = nil
      } else {
        var effectModeOverrides = self.effectModeOverrides ?? [:]
        effectModeOverrides[effectId] = effectMode
        self.effectModeOverrides = effectModeOverrides
      }
    }
    
    if self.effectModeOverrides?.isEmpty == true {
      self.effectModeOverrides = nil
    }
    
    if let fit = self.fit {
      // msgs = MsgHelper.get_effects_status_update_msgs(self)
      // fit.publish_bulk(msgs)
    }
    
  }
  
  /*
   # Autocharge methods
   @property
   def autocharges(self):
       """Returns map which contains charges, 'autoloaded' by effects.

       These charges will always be on item as long as item type defines them.
       """
       # Format {effect ID: charge item}
       return self.__autocharges or {}
   */
  
  var autocharges: [Int64: AutoCharge] = [:]
  
    /*
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
     */
  
  func addAutoCharge(effectId: Int64, autoChargeTypeId: Int64) {
    
  }
}



struct EffectData {
  let effect: Effect
  let mode: EffectMode
  let status: Bool
  // effect, mode (effect run mode), status (effect run status)
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
