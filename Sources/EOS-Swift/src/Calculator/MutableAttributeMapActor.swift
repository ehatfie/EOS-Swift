//
//  MutableAttributeMapActor.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 4/19/26.
//
// https://github.com/pyfa-org/eos/blob/master/eos/calculator/map.py

import Foundation

/*
 Map which contains modified attribute values.

 It provides some of facilities which help to calculate, store and provide
 access to modified attribute values.

 Actor-isolated version of MutableAttributeMap.
 */
public actor MutableAttributeMapActor {
    // New
    let dataSource: DataSource? = nil

    var modifiedAttributes: [Int64: Double] = [:]
    var overrideCallbacks: [Int64: () -> Double]? = nil

    /// Returns map which defines value caps.
    /// It includes attributes which cap something, and attributes being capped by them.
    var capMap: KeyedStorage<AttrId, Int64>?

    var length: Int {
        return keys.count
    }

    var keys: [Int64] {
        var returnValues: Set<Int64> = Set(modifiedAttributes.keys.map(\.self))

        if let item = self.item {
            let typeAttrs = Set(item.typeAttributes.keys.map(\.self))
            returnValues = returnValues.union(typeAttrs)
        }
        let overrideCallbacks = Set((self.overrideCallbacks ?? [:]).keys)
        returnValues = returnValues.union(overrideCallbacks)
        return Array(returnValues)
    }

    var items: [(Int64, Double)] {
        let foo: [(Int64, Double)] = keys.compactMap { attributeId -> (Int64, Double)? in
            guard let val = self.getValue(attributeId: attributeId) else { return nil }
            return (attributeId, val)
        }
        return foo
    }

    weak var item: (any BaseItemMixinProtocol)?

    init(item: any BaseItemMixinProtocol) {
        self.item = item
        self.modifiedAttributes = [:]
    }

    func getValue(attributeId: AttrId) -> Double? {
        return getValue(attributeId: attributeId.rawValue)
    }

    func getValue(attributeId: Int64) -> Double? {
        print("^^ MutableAttributeMapActor - getValue \(attributeId)")
        if let overrideCallbacks,
           let _ = overrideCallbacks[attributeId]
        {
            print("TODO: getValue callback")
            return nil
        }

        guard let value = self.modifiedAttributes[attributeId] else {
            do {
                let value = try self.calculate(attributeId: attributeId)
              print("++ getValue returning calculated value \(String(describing: value))")
                return value
            } catch let err {
                print("!! calc error \(err)")
                return nil
            }
        }
        print("++ getValue returning")
        return value
    }

    func getItem(attrId: Int64) -> Double? {
        if let overrideCallbacks, overrideCallbacks.contains(where: { $0.key == attrId }) {
            return nil
        }
        if let value = self.modifiedAttributes[attrId] {
            return value
        } else {
            let value = try? self.calculate(attributeId: attrId)
            self.modifiedAttributes[attrId] = value
            return value
        }
    }

    /// Reset map to its initial state.
    /// Overrides are not removed. Messages for cleared attributes are not sent.
    func clear() {
        self.modifiedAttributes.removeAll()
        self.capMap = nil
    }

    func removeAll() {

    }

    func capSet(cappingAttrId: AttrId, cappedAttrId: AttrId) {
        if self.capMap == nil {
            self.capMap = KeyedStorage()
        }

        self.capMap?.addDataEntry(key: cappingAttrId, data: cappedAttrId.rawValue)
    }

    func capDel(cappingAttrId: AttrId, cappedAttrId: AttrId) {
        self.capMap?.removeDataEntry(key: cappingAttrId, data: cappedAttrId.rawValue)

        if self.capMap?.dictionary.isEmpty ?? false {
            self.capMap = nil
        }
    }

    /// Force recalculation of attribute with passed ID.
    func forceRecalc(attrId: Int64) -> Bool {
        let removedValue = self.modifiedAttributes.removeValue(forKey: attrId)
        return removedValue != nil
    }

    /// Set override for the attribute in the form of callback.
    func setOverrideCallback(attrId: Int64, callback: @escaping () -> Double) {
        self.overrideCallbacks = [:]
        self.overrideCallbacks?[attrId] = callback
        guard let item = item else {
            return
        }
        let message = AttributesValueChanged(
            attributeChanges: [item as! BaseItemMixin: [attrId]])
        self.publish(message: message)
    }

    /// Remove override callback from attribute.
    func delOverrideCallback(attrId: Int64) {
        let _ = self.overrideCallbacks?.removeValue(forKey: attrId)

        if let oc = self.overrideCallbacks, oc.isEmpty {
            self.overrideCallbacks = nil
        }

        let message = AttributesValueChanged(
            attributeChanges: [item as! BaseItemMixin: [attrId]])
        self.publish(message: message)
    }

    /// Notify everyone that callback value may change.
    /// When originator of callback knows that callback return value may (or will) change for an attribute,
    /// it should invoke this method.
    func overrideValueMayChange(attrId: Int64) {
        let message = AttributesValueChanged(
            attributeChanges: [item as! BaseItemMixin: [attrId]])
        self.publish(message: message)
    }

    /// Get attribute value without using overrides.
    func getWithoutOverrides(attrId: Int64, defaultVal: Double? = nil) -> Double? {
        if let value = self.modifiedAttributes[attrId] {
            return value
        } else if let value = try? self.calculate(attributeId: attrId) {
            self.modifiedAttributes[attrId] = value
            return value
        } else {
            return defaultVal
        }
    }
}

// MARK: - Calculate

extension MutableAttributeMapActor {

    /// Run calculations to find the actual value of attribute.
    ///
    /// - Parameters:
    ///    - attributeId: ID of attribute to be calculated.
    ///
    /// - Returns: Calculated attribute value.
    ///
    /// - Throws:
    ///   - `AttrMetadataError`: If metadata of attribute being calculated cannot be fetched.
    ///   - `BaseValueError`: If base value for attribute being calculated cannot be found.

    func calculate(attributeId: Int64) throws -> Double? {
      let logStuff: Bool = attributeId == AttrId.capacity.rawValue

        if logStuff {
            print("++ calculate \(attributeId)")
        }

        guard let item = self.item else {
            print("++ calculate no item")
            return nil
        }

        if logStuff {
          print("++ calculate for item \(String(describing: item.itemType?.name))")
            print("")
        }
        guard let attribute = item.fit?.solarSystem?.source?.cacheHandler.getAttribute(attributeId: attributeId) else {
            if logStuff {
              print("++ calculate no something fit: \(String(describing: item.fit)) system \(String(describing: item.fit?.solarSystem)) source \(String(describing: item.fit?.solarSystem?.source)) cacheHandler \(String(describing: item.fit?.solarSystem?.source?.cacheHandler))")
            }

            return nil
        }

        var value = item.typeAttributes[attributeId, default: Double(attribute.default_value)]

        if logStuff {
          print("++ got type attributes \(String(describing: item.typeAttributes[attributeId])) in \(item.typeAttributes)")
        }

        var stack: [ModOperator: [Double]] = [:]
        var stackPenalized: [ModOperator: [Double]] = [:]
        var aggregateMin: [TwoKey<ModOperator, AnyHashable?>: [(Double, Bool)]] = [:]
        var aggregateMax: [TwoKey<ModOperator, AnyHashable?>: [(Double, Bool)]] = [:]

        let foo = item.fit?.solarSystem?.calculator.getModifications(
            affecteeItem: item,
            affecteeAttributeId: attributeId
        )

        if logStuff {
          print("+++ modifications for \(attributeId) \(String(describing: foo?.count))")
            print()
        }

        for value in foo ?? [] {
            guard let modOperator = value.modOperator else {
                print("++ no mod operator for \(value)")
                continue
            }

            guard var modValue = value.modValue else {
                print("++ no modValue for \(value)")
                continue
            }

            guard let res = value.resistValue else {
                print("++ no res for ")
                continue
            }

            guard let affectorItem = value.affectorItem else {
                print("++ no affectorItem")
                continue
            }

            // Normalize operations to just three types: assignments, additions, reduced multiplications
            guard let normalizationFunc = normalizers[modOperator] else {
                print("++ malformed")
                continue
            }
            let aggregateKey = value.aggregateKey

            print("++ calculating for \(attributeId) value \(res) modValue \(modValue)")
            // Resistance attribute actually defines resonance, where 1 means 0%
            // resistance and 0 means 100% resistance
            modValue = normalizationFunc(modValue) * res
            var penaltyImmune: Bool = true
            if let typeCategoryId = TypeCategoryId(rawValue: affectorItem.itemType!.categoryId) {
                penaltyImmune = PENALTY_IMMUNE_CATEGORY_IDS.contains(typeCategoryId)
            }

            // Decide if modification should be stacking penalized or not
            let penalize: Bool =
                !attribute.stackable &&
                !penaltyImmune &&
                PENALIZABLE_OPERATORS.contains(modOperator)

            guard let modAggregateMode = value.aggregateMode else {
                continue
            }

            if modAggregateMode == .stack {
                print("++ stack aggregate mode penalize \(penalize)")
                if penalize {
                    stackPenalized[modOperator, default: []].append(modValue)
                } else {
                    stack[modOperator, default: []].append(modValue)
                }
            } else if modAggregateMode == .minimum {
                print("++ minimum aggregate mode penalize \(penalize)")
                let key: TwoKey<ModOperator, AnyHashable?> = TwoKey(
                    values: (modOperator, aggregateKey)
                )
                aggregateMin[key, default: []].append((modValue, penalize))
            } else if modAggregateMode == .maximum {
                print("++ maximum aggregate mode penalize \(penalize)")
                let key: TwoKey<ModOperator, AnyHashable?> = TwoKey(
                    values: (modOperator, aggregateKey)
                )
                aggregateMax[key, default: []].append((modValue, penalize))
            }
        }

        print("++ aggregateMin \(aggregateMin) aggregateMax \(aggregateMax)")
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

        // When data gathering is complete, process penalized modifications. They
        // are penalized on per-operator basis
        print("++ returning value \(value) for \(attributeId)")
        if value == -55 {
            print()
        }

        for (modOperator, modValues) in stackPenalized {
            let penalizedValue = self.penalizeValues(modValues: modValues)
            print("++ penalized value \(modValues) modOperator \(modOperator)")
            stack[modOperator, default: []].append(penalizedValue)
        }
        print("++ stack \(stack)")
        for (key, values) in stack.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let modOperator = key
            let modValues = values

            print("++ inside thing modOperator \(modOperator) modValue \(modValues)")
            if ASSIGNMENT_OPERATORS.contains(modOperator) {
                value = attribute.high_is_good
                    ? modValues.max()!
                    : modValues.min()!
            } else if ADDITION_OPERATORS.contains(modOperator) {
                for modValue in modValues {
                    value += modValue
                }
            } else if MULTIPLICATION_OPERATORS.contains(modOperator) {
                for modValue in modValues {
                    print("++ value pre \(value) against modValue \(modValue)")
                    value *= 1 + modValue
                    print("++ value post \(value)")
                }
            } else {
                print("++ modOperator \(modOperator) not included in")
            }
        }

        // If attribute has upper cap, do not let its value to grow above it
        if let maxAttributeId = attribute.max_attr_id {
            if let maxValue = self.getValue(attributeId: maxAttributeId) {
                print("++ max value for \(attributeId) is \(maxValue) vs current \(value)")
                value = min(maxValue, value)
            }
        }
        // Some of attributes are rounded for whatever reason, deal with it after
        // all the calculations

        if let attrId = AttrId(rawValue: attributeId), LIMITED_PRECISION_ATTR_IDS.contains(attrId) {
            print("++ rounding \(value)")
            value = round(value * 100) / 100
        }

        if logStuff {
            print("+++ calculate \(attributeId) value \(value)")
        }
        print("++ calculate for \(attributeId) returning value \(value)")
        return value
    }

    /// Calculate aggregated reduced multiplier.
    ///
    /// Assuming all multipliers received should be stacking penalized, and that
    /// they are normalized to reduced multiplier form, calculate final
    /// reduced multiplier.
    func penalizeValues(modValues: [Double]) -> Double {
        var chainPositive: [Double] = []
        var chainNegative: [Double] = []
        print(";; penalize values \(modValues)")
        for modValue in modValues {
            modValue >= 0 ? chainPositive.append(modValue) : chainNegative.append(modValue)
        }
        chainPositive.sort(by: <)
        chainNegative.sort(by: >)
        print(";; made pos \(chainPositive) and neg \(chainNegative)")
        var value: Double = 1

        for values in [chainPositive, chainNegative] {
            var chainValue: Double = 1

            for (offset, modValue) in values.enumerated() {
                let power = pow(Double(offset), 2)
                let stackingPenalty = exp(-pow(Double(offset - 1), 2) * 0.14)

                print(";; power for offset \(offset) modValue \(modValue) is \(power) penalty \(stackingPenalty)")
                chainValue *= 1 + (modValue * stackingPenalty)
                print(";; chainValue is \(chainValue)")
                value *= chainValue
            }
        }

        let returnValue = value - 1

        print("++ penalizeValues \(modValues) to \(returnValue)")

        return returnValue
    }

    func publish(message: any Message) {
        self.item?.fit?.publish(message: message)
    }
}

