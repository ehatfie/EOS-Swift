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
  case groupIDs = "groupIDs"
  case typeIDs = "typeIDs"
  case dogmaAttrbutes = "dogmaAttributes"
  case dogmaEffects = "dogmaEffects"
  case typeDogma = "typeDogma"
  case dogmaAttributeCategories = "dogmaAttributeCategories"
  case typeDogmaInfo = "typeDogmaInfo"
  case typeMaterials = "typeMaterials"
  case blueprints = "blueprints"
  case races = "races"
  case marketGroups = "marketGroups"
}

class YamlCacheHandler: BaseCacheHandlerProtocol, @unchecked Sendable {
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
    
    //let foo = readYamlAsync(for: ., type: <#T##(Decodable & Sendable).Type#>)
    // verify file exists
    guard let path = Bundle.main.path(forResource: "", ofType: "Yaml") else {
      return
    }
    if #available(macOS 10.15, *) {
      Task {
        let types = (try? await readYamlAsync(for: .typeIDs, type: TypeData.self)) ?? []
        let attributes = (try? await readYamlAsync(for: .dogmaAttrbutes, type: DogmaAttributeData.self)) ?? []
        let effects = (try? await readYamlAsync(for: .dogmaEffects, type: DogmaEffectData.self)) ?? []
        
      }
    } else {
      // Fallback on earlier versions
    }
    // load types
    // load attributes
    // load effects
    
  }
}

extension Yams.Node: @unchecked @retroactive Sendable {
  
}

extension YamlCacheHandler {
  func readYamlAsync<T: Decodable & Sendable>(for fileName: YamlFiles, type: T.Type, splits: Int = 3) async throws -> [(Int64, T)] {
    guard let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "yaml") else {
      throw NSError(domain: "", code: 0)
    }
    
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!
    
    let node = try Yams.compose(yaml: yaml)!
    
    return await decodeNodeAsync(node: node, type: T.self, splits: splits)
  }
  
  func decodeNodeAsync<T: Decodable & Sendable>(node: Yams.Node, type: T.Type, splits: Int = 2) async -> [(Int64, T)] {
    guard let mapping = node.mapping else {
      print("NO MAPPING")
      return []
    }
    
    let keyValuePair = mapping.map { $0 }
    if #available(macOS 10.15, *) {
      //let start = Date()
      let values = await withTaskGroup(of: [(Int64, T)].self, returning: [(Int64, T)].self) { taskGroup in
        var returnValues = [(Int64, T)]()
        
        taskGroup.addTask { [weak self] in
          return await self?.splitAndSortAsync(splits: splits, some: keyValuePair, type: type) ?? []
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
  
  func splitAndSortAsync<T: Decodable & Sendable>(splits: Int, some: [Node.Mapping.Element], type: T.Type) async -> [(Int64, T)] {
    let keyValueCount = some.count
    
    let one = Array(some[0 ..< keyValueCount / 2])
    let two = Array(some[keyValueCount / 2 ..< keyValueCount])
    
    guard splits > 0 else {
      return await decode(splits: 0, some: some, type: type)
    }
    
    if #available(macOS 10.15, *) {
      let values = await withTaskGroup(of: [(Int64,T)].self, returning: [(Int64,T)].self) { taskGroup in
        var returnValues = [(Int64, T)]()
        
        taskGroup.addTask { await self.splitAndSortAsync(splits: splits - 1, some: one, type: type) }
        taskGroup.addTask { await self.splitAndSortAsync(splits: splits - 1, some: two, type: type) }
        
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
  
  func decode<T: Decodable>(splits: Int, some: [Node.Mapping.Element], type: T.Type) async -> [(Int64, T)] {
    var returnValue: [(Int64,T)] = []
    //print("decode2() - start splits \(splits) for \(some.count)")
    let decoder = YAMLDecoder()
    
    let start = Date()
    some.forEach { key, value in
      guard let keyValue = key.int else { return }
      do {
        let result = try decoder.decode(T.self, from: value)
        
        returnValue.append((Int64(keyValue),result))
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
