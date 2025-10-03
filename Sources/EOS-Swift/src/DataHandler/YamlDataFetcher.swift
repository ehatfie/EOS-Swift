//
//  YamlDataFetcher.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//

import Foundation
import Yams


class YamlDataFetcher: @unchecked Sendable {
  @MainActor static var shared = YamlDataFetcher()
  
  var fetchedResults: [YamlFiles: [(Int64, any Codable & Sendable)]] = [:]
  
  func readYamlAsync<T: Codable & Sendable>(
    for fileName: YamlFiles,
    type: T.Type,
    splits: Int = 3
  ) async throws -> [(Int64, T)] {
    print("++ readYamlAsync \(fileName.rawValue)")
    guard
      let path = Bundle.main.path(
        forResource: fileName.rawValue,
        ofType: "yaml"
      )
    else {
      throw NSError(domain: "", code: 0)
    }
    
    guard fetchedResults[fileName] == nil else {
      print("++ using cached result for \(fileName)")
      return fetchedResults[fileName, default: []] as! [(Int64, T)]
    }
    
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!

    let node = try Yams.compose(yaml: yaml)!
    let decoded = await decodeNodeAsync(node: node, type: T.self, splits: splits)
    fetchedResults[fileName] = decoded
    return decoded
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
        print("Decode error \(err) for \(type) decode")
      }
    }
    //print("decode2() -  took \(Date().timeIntervalSince(start))")
    return returnValue
  }
}
