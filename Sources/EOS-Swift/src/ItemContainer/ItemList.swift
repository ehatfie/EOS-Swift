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
  weak var parent: (any FitHaving)? // ParentHaving??
  var list: [T?] = []
  
  init(parent: any FitHaving) {
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
    self.list.removeAll(where: { $0 == nil })
  }
  
}
