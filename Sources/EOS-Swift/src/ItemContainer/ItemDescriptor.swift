//
//  ItemDescriptor.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

/*
 Container for single item.

 Args:
     attr_name: Name of instance attribute which should be used to store data
         processed by the descriptor.
     item_class: Class of items this container is allowed to contain.
 
 */
class ItemDescriptor<T: BaseItemMixinProtocol>: ItemContainerBase<T>, MaybeFitHaving {
  var fit: Fit?
  
  var item: T?
  
  // Implement this
  override init() {
    super.init()
  }
  
  func get() -> T? {
    return item
  }
  
  func set(item: T, parent: any BaseItemMixinProtocol) throws {
    print("++ ItemDescriptor set")
    let oldItem = self.item
    if let oldItem {
      self.handleItemRemoval(oldItem)
    }
    
    guard let parent = parent as? ItemContainerBaseProtocol else {
      return
    }
    
    self.item = item
    do {
      try self.handleItemAddition(item: item, container: parent)
    } catch let error {
      if let oldItem {
        try self.handleItemAddition(item: oldItem, container: parent)
      }
    }
    
  }
  
  func set1(item: T, parent: any ItemContainerBaseProtocol) throws {
    print("++ ItemDescriptor set")
    let oldItem = self.item
    if let oldItem {
      self.handleItemRemoval(oldItem)
    }
    
    guard let parent = parent as? ItemContainerBaseProtocol else {
      return
    }
    
    self.item = item
    do {
      try self.handleItemAddition(item: item, container: parent)
    } catch let error {
      if let oldItem {
        try self.handleItemAddition(item: oldItem, container: parent)
      }
    }
    
  }
  
  override func handleItemAddition(item: T, container: any ItemContainerBaseProtocol) throws {
    print("++ ItemDescriptor handleItemAddition")
    guard item.container == nil else {
      fatalError("Item already assigned to another container")
    }
    print("++ handleItemAddition \(item.typeId)")
    item.container = container
    print("++ item.container \(item.typeId) set \(item.container)")
    //print("handleItemAddition \()")
    guard let fit = item.fit else {
      print("++ Item no fit")
      return
    }
    
    for subItem in subItemIterator(item: item) {
      print("++ subItem1 for \(item.typeId) is \(subItem.typeId)")
      let messages = MessageHelper.getItemAddedMessages(item: subItem)
      fit.publishBulk(messages: messages)
      subItem.load()
    }
  }
  
}
