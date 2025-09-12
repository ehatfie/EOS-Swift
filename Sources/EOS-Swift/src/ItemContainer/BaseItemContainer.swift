//
//  BaseItemContainer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

protocol ItemContainerBaseProtocol<BaseItemMixinProtocol>: AnyObject {
  associatedtype BaseItemMixinProtocol
  /*
   @property
    def _fit(self):
        return self.__parent._fit
   */
  
  func checkClass(item: BaseItemMixinProtocol) -> Bool
  
  //func handleItemAddition(item: Any, container: Any) {

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
 */

class ItemContainerBase<T: BaseItemMixinProtocol>: ItemContainerBaseProtocol {
  typealias ExpectedItemType = T
  
  
  init() { }
  
  func handleItemAddition(_ item: T, container: ItemContainerBase<BaseItemMixin>) throws {
    guard item.container == nil else {
      fatalError("Item already assigned to another container")
    }
    
    item.container = self
    
    guard let fit = item.fit else {
      print("++ Item no fit")
      return
    }
    
    for subItem in subItemIterator(item: item) {
      subItem.load()
    }
  }
  
  func subItemIterator(item: T) -> AnyIterator<T> {
    var index = 0
    let values = [T]()
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
      //subItem.unload()
      subItem.unload()
      // TODO
//      if fit is not None:
//          msgs = MsgHelper.get_item_removed_msgs(subitem)
//          fit._publish_bulk(msgs)
    }
    item.container = nil
  }
  
  func subitemIterator(item: T) {
    
  }

  /// Check if class of passed item corresponds to our expectations.
  func checkClass(item: any BaseItemMixinProtocol) -> Bool {
    return item is ExpectedItemType
  }
}


