//
//  KeyedStorage.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

public class KeyedStorage<T: Hashable> {
  var dictionary: [AnyHashable: Set<T>] = [:]
  
  func addDataSet(key: AnyHashable, dataSet: [T]) {
    self.dictionary[key, default: Set<T>()].formUnion(dataSet)
  }
  
  func removeDataSet(key: AnyHashable, dataSet: [T]) {
    self.dictionary[key]?.subtract(dataSet)
    if let set = self.dictionary[key], set.isEmpty {
      self.dictionary.removeValue(forKey: key)
    }
  }
  
  func addDataEntry(key: AnyHashable, data: T) {
    self.dictionary[key, default: Set<T>()].formUnion([data])
  }
  
  func removeDataEntry(key: AnyHashable, data: T) {
    if var set = self.dictionary[key] {
      set.remove(data)
      self.dictionary[key] = set
      if set.isEmpty {
        self.dictionary.removeValue(forKey: key)
      }
    }
  }
  
  
  
  
  
}
