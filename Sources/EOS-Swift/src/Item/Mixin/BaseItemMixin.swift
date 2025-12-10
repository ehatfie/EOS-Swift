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

import Foundation

public protocol BaseItemMixinProtocol: AnyObject, Hashable, MaybeFitHaving {
  var id: UUID { get }
  var typeId: Int64 { get }
  var itemType: ItemType? { get set }
  
  var container: (any ItemContainerBaseProtocol)? { get set }
  
  var runningEffectIds: Set<Int64> { get set }
  var effectModeOverrides: [Int64: EffectMode]? { get set }
  var effectTargets: String? { get set }
  var attributes: MutableAttributeMap? { get set } // will be a custom dictionary type
  var autocharges: ItemDict<AutoCharge>? { get set }
  
  var _state: StateI { get set }
  var modifierDomain: ModDomain? { get set }
  var ownerModifiable: Bool { get set }
  var solsysCarrier: Ship? { get set }
  var fit: Fit? { get }
  
  func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol>
  
  var isLoaded: Bool { get }
  func load()
  func unload()
  
  func load(from source: BaseCacheHandlerProtocol)
  
  func clearAutocharges()
  
}

extension BaseItemMixinProtocol {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.typeId == rhs.typeId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    //hasher.combine(ObjectIdentifier(self))
  }
  
//  public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol> {
//    print("!! default childItemIterator impl")
//    var values: [(any BaseItemMixinProtocol)?] = []
//    var index: Int = 0
//    
//    if !skipAutoItems {
//      if let autocharges = self.autocharges {
//        values.append(contentsOf: autocharges.values())
//      }
//    }
//    
//    return AnyIterator {
//      guard index < values.count else { return nil }
//      defer { index += 1 }
//      return values[index]
//    }
//  }
  
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
    let effects = itemType?.effects ?? [:]
    return self.itemType?.effects ?? [:]
  }
  
  var typeDefaultEffect: Any? {
    let itemTypeDefaultEffect = self.itemType?.defaultEffect
    print(":: typeDefaultEffect is \(itemTypeDefaultEffect), hasItemType \(self.itemType != nil)")
    return itemTypeDefaultEffect
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
    print("!! Default Load Implementation")
    // get a getter
    for (effectId, effect) in self.typeEffects {
      //let autoChargeTypeId = effect.getAutoChargeTypeId(item: )
    }
  }
  
  func unload() {
    let fit = self.fit
  
  }

  /// Expose item's effects with item-specific data.
  ///
  /// Returns:
  /// - Map in format {effect ID: (effect, effect run mode, effect run status)}.

  var effects: [Int64: EffectData] {
    var effects: [Int64: EffectData] = [:]
    
    for (key, value) in self.typeEffects {
      let effectMode = self.getEffectMode(effectId: key)
      let status = self.runningEffectIds.contains(key)
      effects[key] = EffectData(effect: value, mode: effectMode, status: status)
    }
    
    if self.typeId == 2301 {
      print(":: effects in \(effects) for item \(itemType?.name)")
    }
    
    return effects
  }
  /*
   """"""
   if self.__effect_mode_overrides is None:
       return DEFAULT_EFFECT_MODE
   return self.__effect_mode_overrides.get(effect_id, DEFAULT_EFFECT_MODE)
   */
  /// Get effect's run mode for this item.
  func getEffectMode(effectId: Int64) -> EffectMode {
    if self.effectModeOverrides == nil {
      return .full_compliance
    }
    
    guard let effectModeOverrides else {
      return .full_compliance
    }
    
    return effectModeOverrides[effectId, default: .full_compliance]
  }
  
  func setEffectMode(effectId: Int64, effectMode: EffectMode) {
    print("++ setEffectMode \(effectId) effectMode \(effectMode)")
    self.setEffectsModes(effectsModes: [effectId: effectMode])
  }
  
//  def _set_effects_modes(self, effects_modes):
  func setEffectsModes(effectsModes: [Int64: EffectMode]) {
    print("++ setEffectModes \(effectsModes)")
    for (effectId, effectMode) in effectsModes {
      print("++ checking effectsModes effectId \(effectId) effectMode \(effectMode)")
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
      let messages = MessageHelper.getEffectsStatusUpdateMessages(item: self)
      fit.publishBulk(messages: messages)
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
  public var id: UUID = UUID()
  
  public var attributes: MutableAttributeMap?
  
  public var userModifiable: Bool
  
  public var typeId: Int64
  public var itemType: ItemType?
  weak public var container: (any ItemContainerBaseProtocol)? = nil
  
  public var runningEffectIds: Set<Int64> = []
  public var effectModeOverrides: [Int64: EffectMode]? = nil
  public var effectTargets: String? = nil
  
  open var _state: StateI
  
  //public var attributes: [AttrId: Double] = [:]
  public var autocharges: ItemDict<AutoCharge>? = nil
  
  public var fit: Fit? {
    if let container = self.container as? MaybeFitHaving {
      return container.fit
    }
    print("-- \(self.typeId) container \(container)")
    return nil
  }
  
  init(typeId: Int64, state: StateI) {
    self.typeId = typeId
    self.itemType = nil
    self.container = nil
    self.effectModeOverrides = nil
    self.effectTargets = nil
    self.autocharges = nil
    self._state = state
    
    self.modifierDomain = .ship
    self.ownerModifiable = false
    self.solsysCarrier = nil
    self.userModifiable = true
    
    self.attributes = MutableAttributeMap(item: self)
    
  }
  
  public static func == (lhs: BaseItemMixin, rhs: BaseItemMixin) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  
  
  
  public func childItemIterator(skipAutoItems: Bool) -> AnyIterator<any BaseItemMixinProtocol> {
    //print("++ open baseItemMixin childItemIterator")
    /*
     if not skip_autoitems:
         for item in self.autocharges.values():
             yield item
     
     try:
         child_item_iter = super()._child_item_iter
     except AttributeError:
         pass
     else:
         for item in child_item_iter(skip_autoitems=skip_autoitems):
             yield item
     */
    var values: [(any BaseItemMixinProtocol)?] = []
    var index: Int = 0
    
    if !skipAutoItems {
      if let autocharges = self.autocharges {
        values.append(contentsOf: autocharges.values())
      }
    }
    
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  /*
   let charge = self.charge.item
   let foo: AnyIterator<any BaseItemMixinProtocol>? = super.childItemIterator(skipAutoItems: false)//.map { $0.next()}
   let bar: [(any BaseItemMixinProtocol)?] = foo?.map { $0 } ?? []
   let values: [(any BaseItemMixinProtocol)?] = [charge] + bar
   var index: Int = 0
   print("++ module childItemIterator value count \(values.count) with \(values)")
   return AnyIterator {
     guard index < values.count else { return nil }
     defer { index += 1 }
     return values[index]
   }
   */
  
  func childItemIter(skipAutoitems: Bool = false)  {
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
    /*
     effects = {}
     for effect_id, effect in self._type_effects.items():
         mode = self.get_effect_mode(effect_id)
         status = effect_id in self._running_effect_ids
         effects[effect_id] = EffectData(effect, mode, status)
     return effects
     */
    var returnValues = [Int64: Effect]()
    
    for value in (self.itemType?.effects ?? [:]) {
      
    }
    
    return returnValues
  }
  
  var typeDefaultEffect: Effect? {
    return self.itemType?.defaultEffect
  }
  
  var typeDefaultEffectId: Int64? {
    return self.itemType?.defaultEffect?.effectId
  }
  
  public var modifierDomain: ModDomain?
  
  public var ownerModifiable: Bool

  public var solsysCarrier: Ship?
  
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

  /// Load item's source-specific data.
  public func load() {
    print("++ loadFor \(self.typeId)")
    let fit = self.fit
    guard let cacheHandler = fit?.solarSystem?.source?.cacheHandler else {
      print("++ no cacheHandler for \(self.typeId) fit: \(fit) solarSystem: \(fit?.solarSystem) source: \(fit?.solarSystem?.source) \(fit?.solarSystem?.source?.cacheHandler)")
      return
    }
    guard let result = cacheHandler.getType(typeId: self.typeId) else {
      print("++ no cache result \(self.typeId)")
      return
    }
    
    self.itemType = result
    print("++ load itemType result \(result.name) effects \(result.effects.map { $0.value.effectId})")
    if let fit = fit {
      let messages = MessageHelper.getItemLoadedMessages(item: self)
      fit.publishBulk(messages: messages)
    }
    
    for (effectId, effect) in self.typeEffects {
      guard let autoChargeTypeId = effect.getAutoChargeTypeId(item: self) else {
        continue
      }
      
      self.addAutoCharge(effectId: effectId, autoChargeTypeId: autoChargeTypeId)
    }
  }
  
  public func load(from source: any BaseCacheHandlerProtocol) {
    guard let result = source.getType(typeId: self.typeId) else {
      print("++ no cache result \(self.typeId)")
      return
    }
    
    self.itemType = result
    print("++ load itemType result \(result.name) effects \(result.effects.map { $0.value.effectId})")
    if let fit = fit {
      let messages = MessageHelper.getItemLoadedMessages(item: self)
      fit.publishBulk(messages: messages)
    }
    
    for (effectId, effect) in self.typeEffects {
      guard let autoChargeTypeId = effect.getAutoChargeTypeId(item: self) else {
        continue
      }
      
      self.addAutoCharge(effectId: effectId, autoChargeTypeId: autoChargeTypeId)
    }
  }
  
  /// Clear items `Source` dependent data
  public func unload() {
    let fit = self.fit
    if let fit = fit, self.isLoaded {
      let messages = MessageHelper.getItemUnloadedMessages(item: self)
      fit.publishBulk(messages: messages)
    }
    self.attributes?.removeAll()
    self.clearAutocharges()
    self.itemType = nil
  }
  
  var effects: [Int64: EffectData] {
    var effects: [Int64: EffectData] = [:]
    
//    for (key, value) in self.typeEffects {
//      let effectMode = self.getEffectMode(effectId: key)
//      let status = self.runningEffectIds.contains(key)
//      effects[key] = EffectData(effect: value, mode: effectMode, status: status)
//    }
    return effects
  }
  
  func getEffectMode(effectId: Int64) -> EffectMode {
    if self.effectModeOverrides == nil {
      return .full_compliance
    }
    
    guard let effectModeOverrides else {
      return .full_compliance
    }
    
    return effectModeOverrides[effectId, default: .full_compliance]
  }
  
  func setEffectMode(effectId: Int64, effectMode: EffectMode) {
    self.setEffectsModes(effectsModes: [effectId: effectMode])
  }
  
//  def _set_effects_modes(self, effects_modes):
  func setEffectsModes(effectsModes: [Int64: EffectMode]) {
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
      let messages = MessageHelper.getEffectsStatusUpdateMessages(item: self)
      fit.publishBulk(messages: messages)
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
  
 
  
  func addAutoCharge(effectId: Int64, autoChargeTypeId: Int64) {
    //
  }
  
  public func clearAutocharges() {
    if let autocharges = self.autocharges {
      autocharges.clear()
      self.autocharges = nil
    }
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
