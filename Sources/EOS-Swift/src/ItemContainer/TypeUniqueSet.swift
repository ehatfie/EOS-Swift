//
//  TypeUniqueSet.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

public class TypeUniqueSet<T: BaseItemMixinProtocol>: ItemSet<T> {
  var typeIdMap: [Int64: T] = [:]
  
  init(parent: MaybeFitHaving) {
    super.init(parent: parent, containerOverride: nil)
  }
  
  override public func add(item: T) {
    let typeId = item.typeId
    
    if typeIdMap[typeId] == nil {
      typeIdMap[typeId] = item
      super.add(item: item)
      // maybe remove here
    }
  }
  
  override public func remove(item: T) {
    super.remove(item: item)
    typeIdMap[item.typeId] = nil
  }
  
  func deleteItem(typeId: Int64) {
    guard let item = self.typeIdMap[typeId] else {
      return
    }
    
    self.remove(item: item)
  }
  
  override func clear() {
    super.clear()
    self.typeIdMap.removeAll()
  }
  
  func getItem(typeId: Int64) -> T? {
    return self.typeIdMap[typeId]
  }
  
  override func contains(item: T) -> Bool {
    return self.typeIdMap[item.typeId] != nil || super.contains(item: item)
  }
}
