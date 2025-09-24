//
//  YamlDataHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/23/25.
//

import Foundation
import Yams

class YamlDataHandler: DataHandlerProtocol, @unchecked Sendable {
  func getEveTypes() async  -> [EveTypeData] {
    return (try? await readYamlAsync(for: .typeIDs, type: EveTypeData.self).map { $0.1 }) ?? []
  }
  
  func getEveGroups() async  -> [EveGroupData] {
    return (try? await readYamlAsync(for: .groupIDs, type: EveGroupData.self).map { $0.1 }) ?? []
  }
  
  func getDogmaAttributes() async -> [DogmaAttributeData] {
    return (try? await readYamlAsync(for: .dogmaAttrbutes, type: DogmaAttributeData.self).map { $0.1 }) ?? []
  }
  
  func getDogmaTypeAttributes() async -> [DogmaTypeAttributeData] {
    return (try? await readYamlAsync(for: .typeDogma, type: DogmaTypeAttributeData.self).map { $0.1 }) ?? []
  }
  
  func getDogmaEffects() async -> [DogmaEffectData] {
    return (try? await readYamlAsync(for: .dogmaEffects, type: DogmaEffectData.self).map { $0.1 }) ?? []
  }
  
  func getDogmaTypeEffects() async  -> [DogmaTypeEffect] {
    var rows: [DogmaTypeEffect] = []
    let result = (try? await readYamlAsync(for: .typeDogmaInfo, type: TypeDogmaData.self)) ?? []
    
    rows = result.flatMap { (typeId, typeData) in
      return typeData.dogmaEffects.map { DogmaTypeEffect(typeId: typeId, effectID: $0.effectID, isDefault: $0.isDefault) }
    }
    
    //let bar = foo.map { DogmaTypeEffect(typeId: $0.0, effectID: <#T##Int64#>, isDefault: <#T##Bool#>)}
    return rows
  }

  func getDebuffCollection() {

  }

  func getSkillReqs() {

  }

  func getTypeFighterabils() {

  }

  func getVersion() -> String {
    return ""
  }
}

extension YamlDataHandler {
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
