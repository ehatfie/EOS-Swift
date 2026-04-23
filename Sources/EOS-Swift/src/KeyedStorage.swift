//
//  KeyedStorage.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

public class KeyedStorage<K: Hashable, T: Hashable> {
  var dictionary: [K: Set<T>] = [:]

  func addDataSet(key: K, dataSet: [T]) {
    self.dictionary[key, default: Set<T>()].formUnion(dataSet)
  }

  func removeDataSet(key: K, dataSet: [T]) {
    self.dictionary[key]?.subtract(dataSet)
    if let set = self.dictionary[key], set.isEmpty {
      self.dictionary.removeValue(forKey: key)
    }
  }

  func addDataEntry(key: K, data: T) {
    self.dictionary[key, default: Set<T>()].formUnion([data])
  }

  func removeDataEntry(key: K, data: T) {
    if var set = self.dictionary[key] {
      set.remove(data)
      self.dictionary[key] = set
      if set.isEmpty {
        self.dictionary.removeValue(forKey: key)
      }
    }
  }
}
