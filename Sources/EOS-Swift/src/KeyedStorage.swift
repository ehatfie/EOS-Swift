//
//  KeyedStorage.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

class KeyedStorage {
  var dictionary: [AnyHashable: Set<AnyHashable>] = [:]
  
  func addDataSet(key: AnyHashable, dataSet: [AnyHashable]) {
    self.dictionary[key, default: Set<AnyHashable>()].insert(dataSet)
  }
  
  func removeDataSet(key: AnyHashable, dataSet: [AnyHashable]) {
    self.dictionary[key]?.subtract(dataSet)
    if let set = self.dictionary[key], set.isEmpty {
      self.dictionary.removeValue(forKey: key)
    }
  }
  
  func addDataEntry(key: AnyHashable, data: AnyHashable) {
    self.dictionary[key, default: Set<AnyHashable>()].insert(data)
  }
  
  func removeDataEntry(key: AnyHashable, data: AnyHashable) {
    if var set = self.dictionary[key] {
      set.remove(data)
      self.dictionary[key] = set
      if set.isEmpty {
        self.dictionary.removeValue(forKey: key)
      }
    }
  }
  
  
  
  
  
}
