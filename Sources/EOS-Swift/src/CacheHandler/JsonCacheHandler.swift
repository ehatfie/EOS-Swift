//
//  JsonCacheHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

nonisolated
class JsonCachehandler: BaseCacheHandlerProtocol, @unchecked Sendable {

  public func updateCache(
    types: [ItemType],
    attributes: [Attribute],
    effects: [Effect],
    buffTemplates: [BuffTemplate],
    fingerprint: String
  ) {
    print(
      "++ JSONCacheHandler updateCache types: \(types.count) attributes: \(attributes) effects: \(effects) fingerprint: \(fingerprint)"
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
//    self.updateMemoryCache2(
//      types: types,
//      attributes: attributes,
//      effects: effects,
//      buffTemplates: buffTemplates
//    )
  }
  
  func getFingerprint() -> String {
    ""
  }
  
  func getType(typeId: Int64) -> ItemType? {
    nil
  }
  
  func getAttribute(attributeId: AttrId) -> Attribute? {
    nil
  }

  var cachePath: String
  
  var typeStore: [Int64: ItemType] = [:]
  var attributeStore: [Int64: Attribute] = [:]
  var effectStore: [Int64: Effect] = [:]
  var buffTemplateStore: [Int64: [BuffTemplate]] = [:]
  var fingerprint: String? = nil
  
  nonisolated
  init(cachePath: String) {
    self.cachePath = cachePath
    Task {
      await self.loadPersistantCache()
    }
    
  }
  
  func getType(typeId: Int64) async -> ItemType? {
    return nil
  }
  
  func getAttribute(attributeId: AttrId) async {
    
  }
  
  func getEffect(effectId: EffectId) -> Effect? {
    nil
  }
  
  func getBuffTemplates(buffId: Int64) {
    
  }
  
  func getFingerprint() {
    
  }
  
  func updateCache(eveObjects: Any, fingerprint: Any) {
    
  }

  nonisolated
  func loadPersistantCache() {
    // verify file exists
    guard let path = Bundle.main.path(forResource: "", ofType: "json") else {
      return
    }
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
