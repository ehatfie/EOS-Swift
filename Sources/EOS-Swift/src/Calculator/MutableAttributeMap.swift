//
//  MutableAttributeMap.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//
// https://github.com/pyfa-org/eos/blob/master/eos/calculator/map.py

/*
 Map which contains modified attribute values.

 It provides some of facilities which help to calculate, store and provide
 access to modified attribute values.

 */
let PENALTY_IMMUNE_CATEGORY_IDS: Set<TypeCategoryId> = Set([
  TypeCategoryId.charge,
  TypeCategoryId.skill,
  TypeCategoryId.implant,
  TypeCategoryId.subsystem
])

let PENALIZABLE_OPERATORS: Set<ModOperator> = [
  ModOperator.pre_mul,
  ModOperator.post_mul,
  ModOperator.post_percent,
  ModOperator.pre_div,
  ModOperator.post_div
]
  
/*
 TypeCategoryId.ship,
 # Tuple with penalizable operators
 PENALIZABLE_OPERATORS = (
     ModOperator.pre_mul,
     ModOperator.post_mul,
     ModOperator.post_percent,
     ModOperator.pre_div,
     ModOperator.post_div)
 */

// TODO: Implement
public class MutableAttributeMap {
  // New
  let dataSource: DataSource? = nil

  // self.__item = item
  var modifiedAttributes: [AttrId: Double] = [:]
  var overrideCallbacks: [Int64: Any]? = nil
  var capMap: [Int64: Int64] = [:]

  var length: Int {
    return keys.count
  }

  var keys: [Int64] {
    /*
     # Return union of attributes from base, modified and override dictionary
     return set(chain(
         self.__item._type_attrs, self.__modified_attrs,
         self.__override_callbacks or {}))
     */
    var returnValues: Set<Int64> = Set(modifiedAttributes.keys.map (\.rawValue))
    
    if let item = self.item {
      let typeAttrs = Set(item.typeAttributes.keys.map(\.rawValue))
      returnValues = returnValues.union(typeAttrs)
    }
    let overrideCallbacks = Set((self.overrideCallbacks ?? [:]).keys)
    returnValues = returnValues.union(overrideCallbacks)
    return Array(returnValues)
  }

  var items: [(AttrId, Double)] {
    let foo: [(AttrId, Double)] = keys.compactMap { value -> (AttrId, Double)? in
      guard let attrId = AttrId(rawValue: value) else { return nil }
      guard let val = self.getValue(attributeId: attrId) else { return nil }
      return (attrId, val)
    }
    // return set((attr_id, self.get(attr_id)) for attr_id in self.keys())
    return foo
  }
  
  weak var item: (any BaseItemMixinProtocol)?

  init(item: any BaseItemMixinProtocol) {
    self.item = item
    self.modifiedAttributes = [:]
  }
  
  /*
   def get(self, attr_id, default=None):
       # Almost copy-paste of __getitem__ due to performance reasons -
       # attribute getters should make as few calls as possible, especially
       # when attribute is already calculated
       if (
           self.__override_callbacks is not None and
           attr_id in self.__override_callbacks
       ):
           callback, args, kwargs = self.__override_callbacks[attr_id]
           return callback(*args, **kwargs)
       try:
           value = self.__modified_attrs[attr_id]
       except KeyError:
           try:
               value = self.__calculate(attr_id)
           except CALCULATE_RAISABLE_EXCEPTIONS:
               return default
           else:
               self.__modified_attrs[attr_id] = value
       return value
   */
  func getValue(attributeId: AttrId) -> Double? {
    print("^^ MutableAttributeMap - getValue \(attributeId)")
    if let overrideCallbacks,
       let callback = overrideCallbacks[attributeId.rawValue]
    {
      print("TODO: getValue callback")
      return nil
      // return callback?()
    }

    guard let value = self.modifiedAttributes[attributeId] else {
      do {
        let value = try self.calculate(attributeId: attributeId)
        print("++ getValue returning calculated value \(value)")
        return value
      } catch let err {
        print("!! calc error \(err)")
        return nil
      }
    }
    print("++ getValue returning")
    return value
  }
  
  subscript(_ attributeId: AttrId, default defaultValue: @autoclosure () -> Double) -> Double {
      get {
          // Return an appropriate subscript value here.
        return self.getValue(attributeId: attributeId) ?? defaultValue()
      }
      set(newValue) {
        return
      }
  }
  
  subscript(_ attributeId: AttrId) -> Double? {
      get {
          // Return an appropriate subscript value here.
        return self.getValue(attributeId: attributeId)
      }
      set(newValue) {
        return
      }
  }

  func getItem() -> Attribute? {
    /*
     if (
                 self.__override_callbacks is not None and
                 attr_id in self.__override_callbacks
             ):
                 callback, args, kwargs = self.__override_callbacks[attr_id]
                 return callback(*args, **kwargs)
             # If no override is set, use modified value. If value is stored in
             # modified map, it's considered valid
             try:
                 value = self.__modified_attrs[attr_id]
             # Else, we have to run full calculation process
             except KeyError:
                 try:
                     value = self.__calculate(attr_id)
                 except CALCULATE_RAISABLE_EXCEPTIONS as e:
                     raise KeyError(attr_id) from e
                 else:
                     self.__modified_attrs[attr_id] = value
             return value
    
     */
    return nil
  }
  
  func removeAll() {
    
  }
}

struct MockAttribute {
  let defaultValue: Int64 = 0
  static let empty = MockAttribute()
}

extension MutableAttributeMap {

  /// - Parameters
  ///
  ///Run calculations to find the actual value of attribute.
  ///
  /// - Parameters:
  ///    - attr_id: ID of attribute to be calculated.

  /// - Returns:
  ///   - Calculated attribute value.

  /// - Throws:
  ///   - `AttrMetadataError`: If metadata of attribute being calculated cannot be fetched.
  ///   - `BaseValueError`: If base value for attribute being calculated cannot be found.
  func calculate(attributeId: AttrId) throws -> Double? {
    print("++ calculate \(attributeId) \(attributeId.rawValue)")
    guard let item = self.item else {
      print("++ calculate no item")
      return nil
    }
    guard let attribute  = item.fit?.solarSystem?.source?.cacheHandler.getAttribute(attributeId: attributeId) else {
      print("++ calculate no something fit: \(item.fit) system \(item.fit?.solarSystem) source \(item.fit?.solarSystem?.source) cacheHandler \(item.fit?.solarSystem?.source?.cacheHandler)")
      return nil
    }
    if attributeId == .cpu_output {
      print("")
    }
    let value = item.typeAttributes[attributeId, default: Double(attribute.default_value)]
    print("++ got type attributes \(item.typeAttributes[.cpu_output])")
    //print("++ default value \(value)")
    var stack: [ModOperator: [Double]] = [:]
    var stackPenalized: [ModOperator: [Double]] = [:]
    var aggregateMin: [TwoKey<ModOperator, AnyHashable>: [(Double, Bool)]] = [:]
    var aggregateMax: [TwoKey<ModOperator, AnyHashable>: [(Double, Bool)]] = [:]
    // get the items related fit and its attached solarsystem and its attached calculator and call a function
    //item._fit.solar_system.source.cache_handler.get_attr(attr_id)

    
    let foo = item.fit?.solarSystem?.calculator.getModifications(affecteeItem: item, affecteeAttributeId: attributeId) ?? []
    
      // Normalize operations to just three types: assignments, additions, reduced multiplications
    for value in foo {
      guard let modOperator = value.modOperator else {
         continue
      }
      
      guard var modValue = value.attributeValue else {
        continue
      }
      
      guard let res = value.resistValue else {
        continue
      }
      
      guard let affectorItem = value.affectorItem else {
        continue
      }
      
      guard let normalizationFunc = normalizers[modOperator] else {
        print("++ malformed")
        continue
      }
      
      guard let aggregateKey = value.aggregateKey else {
        continue
      }
      
      modValue = normalizationFunc(modValue) * res
      
      let penalize: Bool =
        !attribute.stackable &&
        !PENALTY_IMMUNE_CATEGORY_IDS.contains(
          TypeCategoryId(rawValue: affectorItem.itemType!.categoryId)!
        ) &&
        PENALIZABLE_OPERATORS.contains(modOperator)
      
      guard let modAggregateMode = value.aggregateMode else {
        continue
      }

      if modAggregateMode == .stack {
        if penalize {
          stackPenalized[modOperator, default: []].append(modValue)
        } else {
          stack[modOperator, default: []].append(modValue)
        }
      } else if modAggregateMode == .minimum {
        let key: TwoKey<ModOperator, AnyHashable> = TwoKey(
          values: (modOperator, aggregateKey)
        )
        aggregateMin[key, default: []].append((modValue, penalize))
      } else if modAggregateMode == .maximum {
        let key: TwoKey<ModOperator, AnyHashable> = TwoKey(
          values: (modOperator, aggregateKey)
        )
        aggregateMax[key, default: []].append((modValue, penalize))
      }
    }
    
    var minClosure: (Double, Bool) -> Bool = { one, two in
      return false
    }
    
    var closure2: (Double, Bool) -> Bool = { one, two in
      return false//(one, !two)
    }

//    let maxResult = aggregateMax.max(by: { one, two in
//      one.value.0 > two.value.0 && one.value.1 != two.value.1
////      if one.value.0 == two.value.0 {
////        if one.value.1 == true {
////          return two.value.1 == false
////        } else {
////          return two.value.1 == false
////        }
////      } else {
////        return one.value.0 > one.value.0
////      }
//      //one.value.0 < two.value.0 && one.value.1 == two.value.1
//    })! as (key: TwoKey<ModOperator, AnyHashable>, value: (Double, Bool))
//     
    
    for (key, value) in aggregateMin {
      let modOperator = key.values.0
          let minResult = value.min(by: { one, two in
            one.0 < two.0 && one.1 == two.1
          })! as (Double, Bool)
      if minResult.1 {
        stackPenalized[modOperator, default: []].append(minResult.0)
      } else {
        stack[modOperator, default: []].append(minResult.0)
      }
    }
    
    for (key, value) in aggregateMax {
      let modOperator = key.values.0
      let maxResult = value.max(by: { one, two in
        one.0 < two.0 && one.1 != two.1
      })! as (Double, Bool)
      if maxResult.1 {
        stackPenalized[modOperator, default: []].append(maxResult.0)
      } else {
        stack[modOperator, default: []].append(maxResult.0)
      }
    }
    /*
     for container, aggregate_func, sort_func in (
         (aggregate_min, min, lambda i: (i[0], i[1])),
         (aggregate_max, max, lambda i: (i[0], not i[1]))
     ):
         for k, v in container.items():
             mod_operator = k[0]
             
             mod_value, penalize = aggregate_func(v, key=sort_func)
             if penalize:
                 stack_penalized.setdefault(mod_operator, []).append(
                     mod_value)
             else:
                 stack.setdefault(mod_operator, []).append(mod_value)
     */
    
    print("++ returning value \(value)")
    return value
  }
  /*
   def __calculate(self, attr_id):
       """
       """
       item = self.__item
       # Attribute object for attribute being calculated
       try:
           attr = item._fit.solar_system.source.cache_handler.get_attr(attr_id)
       # Raise error if we can't get metadata for requested attribute
       except (AttributeError, AttrFetchError) as e:
           msg = (
               'unable to fetch metadata for attribute {}, '
               'requested for item type {}'
           ).format(attr_id, item._type_id)
           logger.warning(msg)
           raise AttrMetadataError(attr_id) from e
       # Base attribute value which we'll use for modification
       try:
           value = item._type_attrs[attr_id]
       # If attribute isn't available on item type, base off its default value
       except KeyError:
           value = attr.default_value
           # If item type attribute is not specified and default value isn't
           # available, raise error - without valid base we can't keep going
           if value is None:
               msg = (
                   'unable to find base value for attribute {} on item type {}'
               ).format(attr_id, item._type_id)
               logger.info(msg)
               raise BaseValueError(attr_id)
       # Format: {operator: [values]}
       stack = {}
       # Format: {operator: [values]}
       stack_penalized = {}
       # Format: {(operator, aggregate key): [(value, penalize)]}
       aggregate_min = {}
       # Format: {(operator, aggregate key): [(value, penalize)]}
       aggregate_max = {}
       # Now, go through all affectors affecting our item
       for (
           mod_operator, mod_value, resist_value,
           mod_aggregate_mode, mod_aggregate_key, affector_item) in (
               item._fit.solar_system._calculator.get_modifications(
                   item, attr_id)
       ):
           # Normalize operations to just three types: assignments, additions,
           # reduced multiplications
           try:
               normalization_func = NORMALIZATION_MAP[mod_operator]
           # Log error on any unknown operator types
           except KeyError:
               msg = (
                   'malformed modifier on item type {}: unknown operator {}'
               ).format(affector_item._type_id, mod_operator)
               logger.warning(msg)
               continue
           # Resistance attribute actually defines resonance, where 1 means 0%
           # resistance and 0 means 100% resistance
           mod_value = normalization_func(mod_value) * resist_value
           # Decide if modification should be stacking penalized or not
           penalize = (
               not attr.stackable and
               affector_item._type.category_id not in
               PENALTY_IMMUNE_CATEGORY_IDS and
               mod_operator in PENALIZABLE_OPERATORS)
           if mod_aggregate_mode == ModAggregateMode.stack:
               if penalize:
                   stack_penalized.setdefault(mod_operator, []).append(
                       mod_value)
               else:
                   stack.setdefault(mod_operator, []).append(mod_value)
           elif mod_aggregate_mode == ModAggregateMode.minimum:
               aggregate_min.setdefault(
                   (mod_operator, mod_aggregate_key), []).append(
                   (mod_value, penalize))
           elif mod_aggregate_mode == ModAggregateMode.maximum:
               aggregate_max.setdefault(
                   (mod_operator, mod_aggregate_key), []).append(
                   (mod_value, penalize))
       for container, aggregate_func, sort_func in (
           (aggregate_min, min, lambda i: (i[0], i[1])),
           (aggregate_max, max, lambda i: (i[0], not i[1]))
       ):
           for k, v in container.items():
               mod_operator = k[0]
               mod_value, penalize = aggregate_func(v, key=sort_func)
               if penalize:
                   stack_penalized.setdefault(mod_operator, []).append(
                       mod_value)
               else:
                   stack.setdefault(mod_operator, []).append(mod_value)
       # When data gathering is complete, process penalized modifications. They
       # are penalized on per-operator basis
       for mod_operator, mod_values in stack_penalized.items():
           penalized_value = self.__penalize_values(mod_values)
           stack.setdefault(mod_operator, []).append(penalized_value)
       # Calculate value of non-penalized modifications, according to operator
       # order
       for mod_operator in sorted(stack):
           mod_values = stack[mod_operator]
           # Pick best modification for assignments, based on high_is_good
           # value
           if mod_operator in ASSIGNMENT_OPERATORS:
               if attr.high_is_good:
                   value = max(mod_values)
               else:
                   value = min(mod_values)
           elif mod_operator in ADDITION_OPERATORS:
               for mod_value in mod_values:
                   value += mod_value
           elif mod_operator in MULTIPLICATION_OPERATORS:
               for mod_value in mod_values:
                   value *= 1 + mod_value
       # If attribute has upper cap, do not let its value to grow above it
       if attr.max_attr_id is not None:
           try:
               max_value = self[attr.max_attr_id]
           # If max value isn't available, don't cap anything
           except KeyError:
               pass
           else:
               value = min(value, max_value)
               # Let map know that capping attribute restricts current
               # attribute
               self._cap_set(attr.max_attr_id, attr_id)
       # Some of attributes are rounded for whatever reason, deal with it after
       # all the calculations
       if attr_id in LIMITED_PRECISION_ATTR_IDS:
           value = round(value, 2)
       return value
   */
}


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
   */


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


func normalize2(modOperator: ModOperator, value: Double) -> ((Double) -> Double) {
  switch modOperator {
  case .pre_assign: return { $0 }
  case .pre_mul: return { $0 }
  case .pre_div: return { 1 / $0 - 1 }
  case .mod_add: return { $0 }
  case .mod_sub: return { -$0 }
  case .post_mul: return { $0 - 1 }
  case .post_div: return { 1 / $0 - 1 }
  case .post_percent: return { $0 / 100 }
  case .post_assign: return { $0 }
  default: return { $0 }
  }
}

nonisolated(unsafe) let normalizers: [ModOperator: (Double) -> Double] = [
  .pre_assign: { $0 },
  .pre_mul: { $0 },
  .pre_div: { 1 / $0 - 1 },
  .mod_add: { $0 },
  .mod_sub: { -$0 },
  .post_mul: { $0 - 1 },
  .post_div: { 1 / $0 - 1 },
  .post_percent: { $0 / 100 },
  .post_assign: { $0 }
]
let ASSIGNMENT_OPERATORS: [ModOperator] = [.pre_assign, .post_assign]
let ADDITION_OPERATORS: [ModOperator] = [.mod_add, .mod_sub]
let MULTIPLICATION_OPERATORS: [ModOperator] = [
  .pre_mul, .pre_div, .post_mul, .post_mul_immune, .post_div, .post_percent
]
let LIMITED_PRECISION_ATTR_IDS: [AttrId] = [
    AttrId.cpu,
    AttrId.power,
    AttrId.cpu_output,
    AttrId.power_output]

/*
 ASSIGNMENT_OPERATORS = (
     ModOperator.pre_assign,
     ModOperator.post_assign)
 ADDITION_OPERATORS = (
     ModOperator.mod_add,
     ModOperator.mod_sub)
 MULTIPLICATION_OPERATORS = (
     ModOperator.pre_mul,
     ModOperator.pre_div,
     ModOperator.post_mul,
     ModOperator.post_mul_immune,
     ModOperator.post_div,
     ModOperator.post_percent)
 */


// appropriated from https://stackoverflow.com/questions/24131323/in-swift-can-i-use-a-tuple-as-the-key-in-a-dictionary
struct TwoKey<T:Hashable, U:Hashable> : Hashable {
  let values : (T, U)

  var hashValue : Int {
      get {
          let (a,b) = values
          return a.hashValue &* 31 &+ b.hashValue
      }
  }
  
  // comparison function for conforming to Equatable protocol
  static func ==(lhs: TwoKey<T,U>, rhs: TwoKey<T,U>) -> Bool {
    return lhs.values == rhs.values
  }
}


