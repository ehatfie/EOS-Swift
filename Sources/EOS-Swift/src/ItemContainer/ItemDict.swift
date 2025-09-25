//
//  ItemDict.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

/*
 Dict-like container for items.

     It contains items keyed against something.

     Args:
         parent: Object, to which this container is attached.
         item_class: Class of items this container is allowed to contain.
         container_override (optional): When this argument is set, its value will
             be assigned as container to all items being added.
 */
public class ItemDict<T: BaseItemMixinProtocol>: MaybeFitHaving {
  public var fit: Fit?
  weak var parent: (any MaybeFitHaving)?
  
  var itemSet: ItemSet<T>
  var keyedItems: [AnyHashable: T] = [:]
  
  init(parent: any MaybeFitHaving, containerOverride: Any?) {
    self.parent = parent
    self.itemSet = ItemSet<T>(parent: parent, containerOverride: containerOverride)
  }
  
  func setItem(key: AnyHashable, item: T) {
    if self.keyedItems[key] != nil {
      fatalError("Item with key \(key) already exists in this container.")
    }
    self.keyedItems[key] = item
    self.itemSet.add(item: item)
  }
  
  func deleteItem(key: T) {
    guard let item = self.keyedItems[key] else {
      return
    }
    
    self.itemSet.remove(item: item)
    self.keyedItems[key] = nil
  }
  
  func clear() {
    self.itemSet.clear()
    self.keyedItems.removeAll()
  }
  
  func getItem(key: T, defaultValue: (any BaseItemMixinProtocol)? = nil) -> (any BaseItemMixinProtocol)? {
    return self.keyedItems[key] ?? defaultValue ?? nil
  }
  
  func keys() -> [AnyHashable] {
    return Array(self.keyedItems.keys)
  }
  
  func values() -> [T] {
    
    return Array(self.keyedItems.values)
  }
  
  func contains(_ key: T) -> Bool {
    return self.keyedItems[key] != nil
  }
  
  func length() -> Int {
    return self.keyedItems.count
  }
  
  func iterator() -> AnyIterator<any BaseItemMixinProtocol> {
    var values = Array(self.keyedItems.values)
    var index: Int = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
}
