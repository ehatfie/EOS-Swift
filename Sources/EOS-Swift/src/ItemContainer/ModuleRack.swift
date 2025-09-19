//
//  ModuleRack.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/18/25.
//


/// Container for all module racks.
/// Each rack is actually list container for module items.
class ModuleRack {
  
  let high: ItemList<ModuleHigh>
  let mid: ItemList<ModuleMid>
  let low: ItemList<ModuleLow>
  
  init(high: ItemList<ModuleHigh>, mid: ItemList<ModuleMid>, low: ItemList<ModuleLow>) {
    self.high = high
    self.mid = mid
    self.low = low
  }
  
  
}

/// Item view over all module items within all racks.
class ModuleItemView {
  var racks: ModuleRack
  
  init(racks: ModuleRack) {
    self.racks = racks
  }
  
  func iter() -> AnyIterator<Module> {
    let high = racks.high.list.compactMap { $0 }
    let mid = racks.mid.list.compactMap { $0 }
    let low = racks.low.list.compactMap { $0 }
    let values: [Module] = high + mid + low
    
    var index: Int = 0

    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func contains(value: Module?) -> Bool {
    guard let value = value else {
      return false
    }
    return false
  }
}
