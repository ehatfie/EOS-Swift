//
//  YamlDataHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/23/25.
//

import Foundation
import Yams

public let allowedGroups: Set<Int64> = [27, 77, 508, 89, 53, 55, 74, 372]

public class YamlDataHandler: DataHandlerProtocol, @unchecked Sendable {

  public init() {

  }

  public func getEveTypes() async -> [EveTypeData] {
    let fetcher = await YamlDataFetcher.shared
//    return [
//      EveTypeData(
//        typeID: 2929, groupID: 55, capacity: 3.0, mass: 75, radius: 200, volume: 20)
//    ]
    let results =
      (try? await fetcher.readYamlAsync(for: .typeIDs, type: TypeData.self))
      ?? []
    print("++ getEveTypes results \(results.count)")
    return results.compactMap { value -> EveTypeData? in
      let typeId = value.0
      let data = value.1
      guard let groupID = data.groupID, allowedGroups.contains(groupID) else { return nil }
      if typeId == 2929 {
        print(EveTypeData(
          name: data.name!.en!,
          typeID: typeId,
          groupID: data.groupID,
          capacity: data.capacity,
          mass: data.mass,
          radius: data.radius,
          volume: data.volume
        ))
      }
      return EveTypeData(
        name: data.name!.en!,
        typeID: typeId,
        groupID: data.groupID,
        capacity: data.capacity,
        mass: data.mass,
        radius: data.radius,
        volume: data.volume
      )
    }
  }

  public func getEveGroups() async -> [EveGroupData] {
    print("++ getEveGroups")
    let fetcher = await YamlDataFetcher.shared
    let results =
      (try? await fetcher.readYamlAsync(for: .groupIDs, type: GroupData.self))
      ?? []

    let eveGroupData = results.map {
      EveGroupData(groupID: $0.0, categoryID: $0.1.categoryID)
    }

    return eveGroupData
  }

  public func getDogmaAttributes() async -> [DogmaAttributeData] {
    let fetcher = await YamlDataFetcher.shared
    return
      (try? await fetcher.readYamlAsync(
        for: .dogmaAttrbutes,
        type: DogmaAttributeData.self
      ).map { $0.1 }) ?? []
  }
  
  public func getDogmaAttributesDict() async -> [Int64: DogmaAttributeData] {
    let fetcher = await YamlDataFetcher.shared
    let data = (try? await fetcher.readYamlAsync(
      for: .dogmaAttrbutes,
      type: DogmaAttributeData.self
    )) ?? []
    
    var returnData: [Int64: DogmaAttributeData] = [:]
    for(key, value) in data {
      returnData[key] = value
    }
    return returnData
  }

  public func getDogmaTypeAttributes() async -> [DogmaTypeAttributeData] {
    let fetcher = await YamlDataFetcher.shared
    let foo = (try? await fetcher.readYamlAsync(
      for: .typeDogma,
      type: TypeDogmaAttributeDataOuter.self
    )) ?? []
    let bar = foo.flatMap { value in
      return (value.0, value.1)
    }
    
    let bar1 = foo.map { value in
      let value1 = value.1
      return value1.dogmaAttributes.map { value2 in
        return (value.0, value2)
      }
    }
    let res = bar1.flatMap { $0 }
    
    return res.map {
      DogmaTypeAttributeData(
        typeID: $0.0,
        attributeID: $0.1.attributeID,
        value: $0.1.value
      )
    }
    //return bar1.flatMap { $0 }
      
  }
  
  public func getDogmaTypeAttributesDict() async -> [DogmaTypeAttributeData] {
    let fetcher = await YamlDataFetcher.shared
    let foo: [(Int64, TypeDogmaAttributeDataOuter)] = (try? await fetcher.readYamlAsync(
      for: .typeDogma,
      type: TypeDogmaAttributeDataOuter.self
    )) ?? []
    
    
//    let bar = foo.flatMap { value in
//      return (value.0, value.1)
//    }

    var returnValues: [Int64: DogmaTypeAttributeData] = [:]
    for value in foo {
      
      //returnValues[value.0] = DogmaTypeAttributeD
    }
    
    let bar1: [[(Int64, TypeDogmaAttributeData)]] = foo.map { value in
      let value1 = value.1
      return value1.dogmaAttributes.map { value2 in
        return (value.0, value2)
      }
    }
    
    let res: [(Int64, TypeDogmaAttributeData)] = bar1.flatMap { $0 }
    let returnVals: [DogmaTypeAttributeData] = res.map {
      DogmaTypeAttributeData(
        typeID: $0.0,
        attributeID: $0.1.attributeID,
        value: $0.1.value
      )
    }
    for value in returnVals {
      
    }
    return returnVals
    //return bar1.flatMap { $0 }
      
  }

  public func getDogmaEffects() async -> [DogmaEffectData] {
    let fetcher = await YamlDataFetcher.shared
    return
      (try? await fetcher.readYamlAsync(
        for: .dogmaEffects,
        type: DogmaEffectData.self
      ).map { $0.1 }) ?? []
  }

  public func getDogmaTypeEffects() async -> [DogmaTypeEffect] {
    let fetcher = await YamlDataFetcher.shared
    var rows: [DogmaTypeEffect] = []
    let result =
      (try? await fetcher.readYamlAsync(
        for: .typeDogma,
        type: TypeDogmaAttributeDataOuter.self
      )) ?? []
    print("++ getDogmaTypeEffects \(result.count) ")
    
    rows = result.flatMap { (typeId, typeData) in
      return typeData.dogmaEffects?.map { value in
        if typeId == 2929 {
          print("&& effectID for \(typeId) is value \(value.effectID)")
        }
        return DogmaTypeEffect(
          typeId: typeId,
          effectID: value.effectID,
          isDefault: value.isDefault
        )
      } ?? []
    }

    //let bar = foo.map { DogmaTypeEffect(typeId: $0.0, effectID: <#T##Int64#>, isDefault: <#T##Bool#>)}
    return rows
  }

  public func getDebuffCollection() async -> [DBuffCollectionsData] {
    let fetcher = await YamlDataFetcher.shared
    return
      (try? await fetcher.readYamlAsync(
        for: .dbuffCollections,
        type: DBuffCollectionsData.self
      ).map { $0.1 }) ?? []
  }

  public func getSkillReqs() async -> [TypeSkillReq] {
    let fetcher = await YamlDataFetcher.shared
    let typeDogmaData =
      (try? await fetcher.readYamlAsync(
        for: .typeDogmaInfo,
        type: TypeDogmaData.self
      )) ?? []

    let primary = AttrId.required_skill_1.rawValue
    let expectedAtrributes: [(AttrId, AttrId)] = [
      (.required_skill_1, .required_skill_1_level),
      (.required_skill_2, .required_skill_2_level),
      (.required_skill_3, .required_skill_3_level),
      (.required_skill_4, .required_skill_4_level),
      (.required_skill_5, .required_skill_5_level),
      (.required_skill_6, .required_skill_6_level),
    ]

    var skillTypeReqs: [TypeSkillReq] = []

    for (typeId, typeDogmaData) in typeDogmaData {
      let data = TypeSkillReq(typeId: typeId, skillTypeId: 0, level: 1)
      let dogmaAttributes = typeDogmaData.dogmaAttributes
      for (requiredSkill, requiredSkillLevel) in expectedAtrributes {
        // this should be a dict
        guard
          let attr1 = dogmaAttributes.first(where: {
            $0.attributeID == requiredSkill.rawValue
          }),
          let attr2 = dogmaAttributes.first(where: {
            $0.attributeID == requiredSkillLevel.rawValue
          })
        else { break }
        skillTypeReqs.append(
          TypeSkillReq(
            typeId: typeId,
            skillTypeId: Int64(attr1.value),
            level: Int64(attr2.value)
          )
        )
      }
    }

    return skillTypeReqs
  }

  public func getTypeFighterabils() {

  }

  public func getVersion() -> String? {
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
        print("Decode error \(err) for \(type) decode")
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
