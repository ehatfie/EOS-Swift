//
//  YamlCacheHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation
import Yams

enum YamlFiles: String {
  case categoryIDs = "categoryIDs"
  case groupIDs = "groups"
  case typeIDs = "types"
  case dogmaAttrbutes = "dogmaAttributes"
  case dogmaEffects = "dogmaEffects"
  case typeDogma = "typeDogma"
  case dogmaAttributeCategories = "dogmaAttributeCategories"
  case typeDogmaInfo = "typeDogmaInfo"
  case typeMaterials = "typeMaterials"
  case blueprints = "blueprints"
  case races = "races"
  case marketGroups = "marketGroups"
  case dbuffCollections = "dbuffCollections"
}

public class YamlCacheHandler: @preconcurrency BaseCacheHandlerProtocol,
  @unchecked Sendable
{
  nonisolated public func getFingerprint() -> String {
    return ""
  }

  var cachePath: String

  var typeStore: [Int64: ItemType] = [:]
  var attributeStore: [Int64: Attribute] = [:]
  var effectStore: [Int64: Effect] = [:]
  var buffTemplateStore: [Int64: [BuffTemplate]] = [:]
  var fingerprint: String? = nil

  private let cache = Cache<Int64, ItemType>()

  public init(cachePath: String) {
    self.cachePath = cachePath

    Task { @MainActor in
      await self.loadPersistantCache()
    }

  }

  public func getType(typeId: Int64) -> ItemType? {
    return self.typeStore[typeId]
  }

  func getsome() {

  }

  nonisolated public func getAttribute(attributeId: AttrId) {

  }

  nonisolated public func getEffect(effectId: EffectId) {

  }

  nonisolated public func getBuffTemplates(buffId: Int64) {

  }

  func getFingerprint() -> Int {
    return 0
  }

  public func updateCache(
    types: [ItemType],
    attributes: [Attribute],
    effects: [Effect],
    buffTemplates: [BuffTemplate],
    fingerprint: String
  ) {
    print(
      "++ YamlCacheHandler updateCache types: \(types.count) attributes: \(attributes.count) effects: \(effects.count) fingerprint: \(fingerprint)"
    )
    /*
     types, attrs, effects, buff_templates = eve_objects
     cache_data = {
         'types':
             [self.__type_compress(t) for t in types],
         'attrs':
             [self.__attr_compress(a) for a in attrs],
         'effects':
             [self.__effect_compress(e) for e in effects],
         'buff_templates':
             [self.__buff_template_compress(t) for t in buff_templates],
         'fingerprint':
             fingerprint}
     self.__update_persistent_cache(cache_data)
     self.__update_memory_cache(cache_data)
     */
    self.updateMemoryCache2(
      types: types,
      attributes: attributes,
      effects: effects,
      buffTemplates: buffTemplates
    )
  }

  func loadPersistantCache() async {
    print("++ YamnlCacheHandler load persistant cache")

    // verify file exists
    guard let path = Bundle.main.path(forResource: "", ofType: "Yaml") else {
      return
    }

    if #available(macOS 10.15, *) {
      //Task { [weak self] in
      //guard let self = self else { return }
      let types =
        (try? await readYamlAsync(for: .typeIDs, type: TypeData.self)) ?? []

      let attributes =
        (try? await self.readYamlAsync(
          for: .dogmaAttrbutes,
          type: DogmaAttributeData.self
        )) ?? []

      let effects =
        (try? await readYamlAsync(
          for: .dogmaEffects,
          type: DogmaEffectData.self
        )) ?? []

      self.updateMemoryCache(
        types: types,
        attributes: attributes,
        effects: effects, fingerPrint: ""
      )
      //}
    } else {
      print("++ load persistant cache fallback")
      // Fallback on earlier versions
    }
    // load types
    // load attributes
    // load effects

  }

  func updatePersistentCache() {
    // write to some file (or our cache?)
  }
  
  func updateMemoryCache2(
    types: [ItemType],
    attributes: [Attribute],
    effects: [Effect],
    buffTemplates: [BuffTemplate],
  ) {
    for each in types {
      typeStore[each.typeId] = each
    }
    
    for row in attributes {
      attributeStore[row.attr_id] = row
    }
    
    for row in effects {
      effectStore[row.effectId] = row
    }
  }

  func updateMemoryCache(
    types: [(Int64, TypeData)],
    attributes: [(Int64, DogmaAttributeData)],
    effects: [(Int64, DogmaEffectData)],
    fingerPrint: String
  ) {
    print(
      "++ YamlCacheHandler updateMemoryCache types: \(types.count) attributes: \(attributes.count) effects:\(types.count)"
    )
    self.typeStore.removeAll()
    self.attributeStore.removeAll()
    self.effectStore.removeAll()

    self.updateEffectStore(effects: effects)

    self.fingerprint = fingerPrint
    print(
      "++ updateMemoryCache done typeStore: \(typeStore.count) attributeStore: \(attributeStore.count) effectStore: \(effectStore.count)"
    )
  }

  func updateTypeStore(types: [(Int64, TypeData)]) {
    
    for type in types {
      let typeId = type.0
      let typeData = type.1
      
      
      
//      let typeModel = ItemType(
//        typeId: typeId,
//        groupId: typeData.groupID!,
//        categoryId: 0, // TODO
//        attributes: <#T##[AttrId : Double]#>,
//        effects: <#T##[EffectId : Effect]#>,
//        defaultEffect: <#T##Effect?#>, // TODO
//        abilitiesData: <#T##[Int64 : (Double, Int)]#>
//      )

    }
  }

  func updateEffectStore(effects: [(Int64, DogmaEffectData)]) {
    for effect in effects {
      let effectData = effect.1
      let modifiers = effectData.modifierInfo?.map { value -> DogmaModifier in
        let modOperator = ModOperator(rawValue: Int(value.operation ?? 0))
        let affecteeFilter: ModAffecteeFilter? = ModAffecteeFilter(
          value: value.func
        )

        let affecteeFilterExtraArg: Int64?
        switch affecteeFilter {
        case .owner_skillrq, .domain_skillrq:
          affecteeFilterExtraArg = value.skillTypeID
        case .domain_group: affecteeFilterExtraArg = value.groupId
        default: affecteeFilterExtraArg = nil
        }

        return DogmaModifier(
          affecteeFilter: affecteeFilter,
          affecteeFilterExtraArg: affecteeFilterExtraArg,
          affecteeDomain: ModDomain(value: value.domain),
          affecteeAtributeId: AttrId(rawValue: value.modifiedAttributeID ?? -1),
          modOperator: modOperator,
          aggregateMode: nil,  // ModAggregateMode?
          aggregateKey: nil,  // AnyHashable?
          affectorAttrId: AttrId(rawValue: value.modifyingAttributeID ?? -1)
        )
      }

      effectStore[effect.0] = Effect(
        effectId: effectData.effectID,
        categoryID: EffectCategoryId(rawValue: effectData.effectCategory),
        isOffensive: effectData.isOffensive,
        isAssistance: effectData.isAssistance,
        durationAttributeID: effectData.durationAttributeID,
        dischargeAttributeID: effectData.dischargeAttributeID,
        rangeAttributeID: effectData.rangeAttributeID,
        falloffAttributeID: effectData.falloffAttributeID,
        trackingSpeedAttributeID: effectData.trackingSpeedAttributeID,
        fittingUseUsageChanceAttributeID: effectData
          .fittingUsageChanceAttributeID,
        resistanceAttributeId: effectData.resistanceAttributeID,
        buildStatus: .none,
        modifiers: modifiers ?? []
      )
    }
  }
}

extension Yams.Node: @unchecked @retroactive Sendable {

}

extension YamlCacheHandler {
  func readYamlAsync<T: Decodable & Sendable>(
    for fileName: YamlFiles,
    type: T.Type,
    splits: Int = 3
  ) async throws -> [(Int64, T)] {
    guard
      let path = Bundle.main.path(
        forResource: fileName.rawValue,
        ofType: "yaml"
      )
    else {
      throw NSError(domain: "", code: 0)
    }

    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!

    let node = try Yams.compose(yaml: yaml)!

    return await decodeNodeAsync(node: node, type: T.self, splits: splits)
  }

  func decodeNodeAsync<T: Decodable & Sendable>(
    node: Yams.Node,
    type: T.Type,
    splits: Int = 2
  ) async -> [(Int64, T)] {
    guard let mapping = node.mapping else {
      print("NO MAPPING")
      return []
    }

    let keyValuePair = mapping.map { $0 }
    if #available(macOS 10.15, *) {
      //let start = Date()
      let values = await withTaskGroup(
        of: [(Int64, T)].self,
        returning: [(Int64, T)].self
      ) { taskGroup in
        var returnValues = [(Int64, T)]()

        taskGroup.addTask { [weak self] in
          return await self?.splitAndSortAsync(
            splits: splits,
            some: keyValuePair,
            type: type
          ) ?? []
        }

        for await result in taskGroup {
          returnValues.append(contentsOf: result)
        }

        return returnValues
      }
      //print("decodeNodeAsync() - splitAndSortAsync done \(Date().timeIntervalSince(start))")
      return values

    } else {
      // Fallback on earlier versions
      return []
    }
  }

  func splitAndSortAsync<T: Decodable & Sendable>(
    splits: Int,
    some: [Node.Mapping.Element],
    type: T.Type
  ) async -> [(Int64, T)] {
    let keyValueCount = some.count

    let one = Array(some[0..<keyValueCount / 2])
    let two = Array(some[keyValueCount / 2..<keyValueCount])

    guard splits > 0 else {
      return await decode(splits: 0, some: some, type: type)
    }

    if #available(macOS 10.15, *) {
      let values = await withTaskGroup(
        of: [(Int64, T)].self,
        returning: [(Int64, T)].self
      ) { taskGroup in
        var returnValues = [(Int64, T)]()

        taskGroup.addTask {
          await self.splitAndSortAsync(
            splits: splits - 1,
            some: one,
            type: type
          )
        }
        taskGroup.addTask {
          await self.splitAndSortAsync(
            splits: splits - 1,
            some: two,
            type: type
          )
        }

        for await result in taskGroup {
          returnValues.append(contentsOf: result)
        }

        return returnValues
      }
      return values
    } else {
      // Fallback on earlier versions
      return []
    }

    //return await firstThing + secondThing
  }

  func decode<T: Decodable>(
    splits: Int,
    some: [Node.Mapping.Element],
    type: T.Type
  ) async -> [(Int64, T)] {
    var returnValue: [(Int64, T)] = []
    //print("decode2() - start splits \(splits) for \(some.count)")
    let decoder = YAMLDecoder()

    let start = Date()
    some.forEach { key, value in
      guard let keyValue = key.int else { return }
      do {
        let result = try decoder.decode(T.self, from: value)

        returnValue.append((Int64(keyValue), result))
      } catch let err {
        print("Decode error \(err) for \(type) decode2")
      }
    }
    //print("decode2() -  took \(Date().timeIntervalSince(start))")
    return returnValue
  }
}

/*
 func readYamlAsync2<T: Decodable>(for fileName: YamlFiles, type: T.Type, splits: Int = 3) async throws -> [(Int64, T)] {
   guard let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "yaml") else {
     throw NSError(domain: "", code: 0)
   }

   let url = URL(fileURLWithPath: path)
   let data = try Data(contentsOf: url)
   let yaml = String(data: data, encoding: .utf8)!

   let node = try Yams.compose(yaml: yaml)!

   return await decodeNodeAsync(node: node, type: T.self, splits: splits)
 }
 */
