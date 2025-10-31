//
//  BaseItemContainer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

public protocol ItemContainerBaseProtocol<ExpectedType>: AnyObject {
  associatedtype ExpectedType
  /*
   @property
    def _fit(self):
        return self.__parent._fit
   */
  
  func checkClass(item: (any BaseItemMixinProtocol)?, allowNil: Bool) -> Bool
  
  func handleItemAddition(item: ExpectedType, container: any ItemContainerBaseProtocol) throws
  func subItemIterator(item: ExpectedType) -> AnyIterator<any BaseItemMixinProtocol>
  func length() -> Int
}

extension ItemContainerBaseProtocol where ExpectedType: BaseItemMixinProtocol {
  public func handleItemAddition(item: ExpectedType, container: any ItemContainerBaseProtocol) throws {
    guard item.container == nil else {
      fatalError("Item already assigned to another container")
    }
    
    item.container = self
    
    //print("handleItemAddition \()")
    guard let fit = item.fit else {
      print("++ Item no fit")
      return
    }
    
    for subItem in subItemIterator(item: item) {
      print("++ subItem for \(item.typeId) is \(subItem.typeId)")
      let messages = MessageHelper.getItemAddedMessages(item: subItem)
      fit.publishBulk(messages: messages)
      subItem.load()
    }
  }
}

public protocol TestItemContainerProtocol<BaseItemMixinProtocol> {
  associatedtype BaseItemMixinProtocol
  
  func handleItemAddition(item: BaseItemMixinProtocol, container: any TestItemContainerProtocol<BaseItemMixinProtocol>)
  func handleItemRemoval(item: BaseItemMixinProtocol)
  
  func subItemIterator(item: BaseItemMixinProtocol) -> AnyIterator<BaseItemMixinProtocol>?
}

class BaseTestItemContainer<T: BaseItemMixinProtocol>: TestItemContainerProtocol {
  typealias BaseItemMixinProtocol = T
  
  func handleItemAddition(item: BaseItemMixinProtocol, container: any TestItemContainerProtocol<BaseItemMixinProtocol>) {
    
  }
  
  func handleItemRemoval(item: BaseItemMixinProtocol) {
    
  }
  
  func subItemIterator(item: BaseItemMixinProtocol) -> AnyIterator<BaseItemMixinProtocol>? {
    return nil
  }
}

/*
 8/7/25 - Pretty sure this is 95% done
 8/18/25 - Maybe this should be a default implementation on ItemContainerBaseProtocol
 */

public class ItemContainerBase<T: BaseItemMixinProtocol>: ItemContainerBaseProtocol {
  public typealias ExpectedType = T
  
  init() { }
  
  public func handleItemAddition(item: T, container: any ItemContainerBaseProtocol) throws {
    guard item.container == nil else {
      fatalError("Item already assigned to another container")
    }
    print("++ handleItemAddition \(item.typeId) \(item.itemType?.name)")
    item.container = container
    print("++ item.container \(item.typeId) set \(item.container)")
    //print("handleItemAddition \()")
    guard let fit = item.fit else {
      print("++ Item no fit1")
      return
    }
    
    for subItem in subItemIterator(item: item) {
      print("++ subItem1 for \(item.typeId) is \(subItem.typeId)")
      let messages = MessageHelper.getItemAddedMessages(item: subItem)
      fit.publishBulk(messages: messages)
      subItem.load()
    }
  }
  
  public func subItemIterator(item: T) -> AnyIterator<any BaseItemMixinProtocol> {
    var index = 0
    var values = [any BaseItemMixinProtocol]()
    let iterResult = item.childItemIterator(skipAutoItems: true).map({ $0 })
    let castIterResult = (iterResult as? [any BaseItemMixinProtocol] ?? [])
    values = [item] + castIterResult
    
    if iterResult.count != castIterResult.count {
      print("++ child item iterator values count mismatch \(iterResult.count) vs \(castIterResult.count)")
      print("++ iterResult: \(iterResult) values \(values)")
    }
    
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func handleItemRemoval(_ item: T) {
    /*
     Do all the generic work to remove item to container.

     Must be called before item has been removed from specific container, so
     that presence checks during removal pass.
     */
    let fit = item.fit
    for subItem in self.subItemIterator(item: item) {
      subItem.unload()
      if let fit = fit {
        let messages = MessageHelper.getItemRemovedMessages(item: subItem)
        fit.publishBulk(messages: messages)
      }
    }
    item.container = nil
  }
  
  func subitemIterator(item: T) {
    print("++ baseItemCOntainer subitemIterator")
  }

  /// Check if class of passed item corresponds to our expectations.
  public func checkClass(item: (any BaseItemMixinProtocol)?, allowNil: Bool) -> Bool {
    guard let item = item else {
      return allowNil
    }
    return item is ExpectedType
  }
  
  public func length() -> Int {
    return 0
  }
}


