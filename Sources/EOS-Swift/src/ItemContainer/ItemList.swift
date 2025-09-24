//
//  ItemList.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/18/25.
//


///Ordered container for items.

/// Implements list-like interface.
/// Params
///    parent: Object, to which this container is attached.
///    item_class: Class of items this container is allowed to contain.



class ItemList<T: BaseItemMixinProtocol>: ItemContainerBase<T> {
  typealias BaseItemMixin = T
  weak var parent: (any MaybeFitHaving)? // ParentHaving??
  var list: [T?] = []
  
  var fit: Fit? {
    return self.parent?.fit
  }
  
  init(parent: any MaybeFitHaving) {
    //super.init(parent: parent)
    self.parent = parent
    self.list = []
  }
  
  /*
      Args:
          index: Position to insert value to.
          value: Item or None. None can be used to insert empty slots between
                  items.

      Raises:
          TypeError: If item of unacceptable class is passed.
          ValueError: If item is passed as value and it cannot be added to
              the container (e.g. already belongs to other container).
   */
  /// Insert value to given position.
  /// If position is out of range of container and value is item, fill container with Nones up to position and put item there.
  func insert(index: Int, value: (any BaseItemMixinProtocol)?) {
    guard self.checkClass(item: value, allowNil: true) else {
      return
    }

    // prevents out of index, perhaps if we added a value to slot 5
    self.allocate(index: index - 1)
    self.list.insert(value as? BaseItemMixin, at: index)
    
    guard let value = value else {
      self.cleanup()
      return
    }
    
    do {
      try self.handleItemAddition(value as! T, container: self)
    } catch let error {
      print("++ ItemList insert item error")
      self.list.remove(at: index)
      self.cleanup()
      // raise ValueError(*e.args) from e
    }
  }
  
  /// Append item to the end of the container.
  func append(item: any BaseItemMixinProtocol) {
    guard self.checkClass(item: item, allowNil: false) else {
      return
    }
    
    self.list.append(item as? T)
    do {
      try self.handleItemAddition(item as! T, container: self)
    } catch let error {
      print("++ ItemList insert error")
      // remove last?
      self.list.removeLast()
      // except ItemAlreadyAssignedError as e:
          // del self.__list[-1]
          // raise ValueError(*e.args) from e
    }
  }
  
  /// Put item to given position.
  /// If position is out of range of container, fill it with Nones up to position and put item there.
  func place(index: Int, item: any BaseItemMixinProtocol) {
    guard self.checkClass(item: item, allowNil: false) else {
      return
    }
    if index >= self.list.count {
      self.allocate(index: index)
    }
    
    let oldItem = self.list[index]
    
    if let oldItem = oldItem {
      // TODO throw SlotTakenError(index)
      return
    }
    
    self.list[index] = item as? T
    
    do {
      try self.handleItemAddition(item as! T, container: self)
    } catch let error {
      print("++ ItemList place error \(error)")
      self.list.remove(at: index)
      self.cleanup()
      // raise ValueError(*e.args) from e
    }
  }
  
  /// Put item to first free slot in container.
  /// If container doesn't have free slots, append item to the end of the container.
  func equip(item: any BaseItemMixinProtocol) {
    guard self.checkClass(item: item, allowNil: false) else {
      return
    }
    let index: Int
    if let foo = self.list.firstIndex(of: nil) {
      index = foo
      self.list[index] = item as? T
    } else {
      index = self.list.count
      self.list.append(item as? T)
    }
    
    do {
      try self.handleItemAddition(item as! T, container: self)
    } catch let error {
      print("++ ItemList equip error \(error)")
      self.list.remove(at: index)
      self.cleanup()
      // raise ValueError(*e.args) from e
    }
  }
  
  /// Remove item or None from the container.
  ///
  /// Also clean container's tail if it's filled with Nones.
  /// Parameters:-
  ///   value: Thing to remove. Can be item, None or integer index.
  func remove(value: Any?) {
    let index: Int?
    let item: T?
    
    if let indexValue = value as? Int {
      index = indexValue
      item = self.list[indexValue]
    } else if let itemValue = value as? (T) {
      item = itemValue
      index = self.list.firstIndex(of: item)
    } else {
      return
    }
    
    if let actualItem = item {
      self.handleItemRemoval(actualItem)
    }
    guard let actualIndex = index else {
      return
    }
    self.list.remove(at: actualIndex)
    self.cleanup()
  }
  
  /// Free item's slot.
  
  /// Or, in other words, replace it with None, without shifting list tail.
  /// Also clean container's tail after replacement, if it's filled with nils.
  func free(value: Any?) {
    let index: Int?
    let item: T?
    
    if let indexValue = value as? Int{
      index = indexValue
      item = self.list[indexValue]
    } else if let itemValue = value as? T {
      item = itemValue
      index = self.list.firstIndex(of: item)
    } else {
      return
    }
    
    guard let actualItem = item else {
      return
    }
    self.handleItemRemoval(actualItem)
    guard let actualIndex = index else {
      return
    }
    self.list[actualIndex] = nil
    self.cleanup()
  }
  
  /// Remove everything from the container.
  func clear() {
    for item in self.list {
      guard let item = item else {
        continue
      }
      self.handleItemRemoval(item)
    }
    
    self.list.removeAll()
  }
  
  
  // MARK: - Non-modifying methods
  
  func getItem(index: Int) -> T? {
    return self.list[index]
  }
  
  func iterator() -> IndexingIterator<[T?]> {
    return list.makeIterator()
  }
  
  func contains(value: T) -> Bool {
    return list.contains(where: {$0 == value})
  }
  
  override func length() -> Int {
    return self.list.count
  }
  
  // MARK: - Auxilary methods
  
  /// Complete list with Nones until passed index becomes accessible.
  /// Used by other methods if index requested by user is out of range.
  func allocate(index: Int) {
    let allocatedCount = self.list.count
    self.list.append(contentsOf: Array(repeating: nil, count: max(index - allocatedCount + 1, 0)))
  }
  
  /// Remove trailing Nones from list.
  func cleanup() {
    
    /*
     try:
         while self.__list[-1] is None:
             del self.__list[-1]
     # If we get IndexError, we've ran out of list elements and we're fine with it
     except IndexError:
         pass
     */
    while self.list.last == nil {
      self.list.removeLast()
    }
  }
  
}
