//
//  JsonCacheHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//
import Foundation

class JsonCachehandler: BaseCacheHandlerProtocol {
  var cachePath: String
  
  var typeStore: [Int64: ItemType] = [:]
  var attributeStore: [Int64: Attribute] = [:]
  var effectStore: [Int64: Effect] = [:]
  var buffTemplateStore: [Int64: [BuffTemplate]] = [:]
  var fingerprint: String? = nil
  
  init(cachePath: String) {
    self.cachePath = cachePath
    
    self.loadPersistantCache()
  }
  
  func getType(typeId: Int64) {
    
  }
  
  func getAttribute(attributeId: AttrId) {
    
  }
  
  func getEffect(effectId: EffectId) {
    
  }
  
  func getBuffTemplates(buffId: Int64) {
    
  }
  
  func getFingerprint() {
    
  }
  
  func updateCache(eveObjects: Any, fingerprint: Any) {
    
  }
  
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
