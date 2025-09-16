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

struct ModificationData {
  let modificationOperator: ModOperator
  let modificationValue: Double
  let resistanceValue: Double //??
  let affectorItem: any BaseItemMixinProtocol
}

class CalculationService: BaseSubscriber {
  var handlerMap: [Int64 : CallbackHandler] = [:]
  
  weak var solarSystem: SolarSystem?
  var affections: AffectionRegister? = nil // AffectionRegister
  var projections: ProjectionRegister? = nil // ProjectionRegister
  // Format: {projector: {modifiers}}
  var warfareBuffs = KeyedStorage()
  
  // Container with affector specs which will receive messages
  // Format: {message type: set(affector specs)}
  var subscribedAffectors = KeyedStorage()
  
  init(solarSystem: SolarSystem) {
    self.solarSystem = solarSystem
  }
  
  func notify(_ message: Any) {
    
  }
  
  /// Get modifications of affectee attribute on affectee item.
  /// - Parameters:
  ///   - affecteeItem: Item, for which we're getting modifications.
  ///   - affecteeAttributeId: Affectee attribute ID; only modifications which influence attribute with this ID will be returned.
  func getModifications(affecteeItem: any BaseItemMixinProtocol, affecteeAttributeId: AttrId) -> [ModificationData] {
    var returnValues: [ModificationData] = []
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
    
    guard let affectorSet = affections.getAffectorSpecs(affecteeItem: affecteeItem) else {
      print("No affectorSpecs")
      return []
    }
    
    let affectorSpecs = affectorSet.compactMap { $0 as? AffectorSpec }
    guard affectorSpecs.count == affectorSet.count else {
      print("mismatch affector count \(affectorSpecs.count) vs \(affectorSet.count)")
      return []
    }
    
    for affectorSpec in affectorSpecs {
      let affectorModifier = affectorSpec.modifier
      let affectorItem = affectorSpec.itemType
      
      guard affectorModifier.affecteeAtributeId == affecteeAttributeId else {
        continue
      }
      //let foo = affectorModifier.getModification
      
    }
    
    return returnValues
  }
}
