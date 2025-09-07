//
//  BaseItemContainer.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//

protocol ItemContainerBaseProtocol<BaseItemMixinProtocol> {
  associatedtype BaseItemMixinProtocol
  
  //var fit: Fit? { get }
  /*
   @property
    def _fit(self):
        return self.__parent._fit
   */
  
  func checkClass(item: BaseItemMixinProtocol) -> Bool
}

class ItemContainerBase<T: BaseItemMixinProtocol>: ItemContainerBaseProtocol {
  typealias ExpectedItemType = T
  
  weak var parent: T?
  
  var fit: Fit? {
    return parent?.fit
  }
  
  var set: Set<T>
  var containerOverride: Bool
  
  init(parent: T?, expectedItemType: T.Type, containerOverride: Bool = false) {
    self.parent = parent
    //self.expectedItemType = expectedItemType
    self.set = []
    self.containerOverride = containerOverride
  }
  
  
  
  func handleItemAddition(_ item: T, container: any ItemContainerBaseProtocol) throws {
    guard item.container == nil else {
      fatalError("Item already assigned to another container")
    }
      //item.container = container
    // let fit = item.fit
  }
  
  func subItemIterator(item: any BaseItemMixinProtocol) -> AnyIterator<T> {
    /*
     open func makeIterator() -> AnyIterator<Double> {
       
     }
     */
    
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
    }
    /*
     for subitem in self.__subitem_iter(item):
         subitem._unload()
         if fit is not None:
             msgs = MsgHelper.get_item_removed_msgs(subitem)
             fit._publish_bulk(msgs)
     item._container = None
     */
  }
  
  func subitemIterator(item: T) {
    
  }
  
  /*
   def _check_class(self, item, allow_none=False):
       """

       Args:
           item: Item which should be checked.
           allow_none (optional): Define if None as item is fine or not. By
               default, it is not.

       Raises:
           TypeError: If item class check fails.
       """
       if isinstance(item, self.__item_class):
           return
       if item is None and allow_none is True:
           return
       msg = 'expected {} instance{}, received {} instead'.format(
           self.__item_class.__qualname__,
           'or None' if allow_none is True else '',
           type(item).__qualname__)
       raise TypeError(msg)
   */
  /// Check if class of passed item corresponds to our expectations.
  func checkClass(item: any BaseItemMixinProtocol) -> Bool {
    return item is ExpectedItemType
  }
  //private var items: Set<T> = []
}
/*
 class ItemContainerBase:
     """Base class for item containers.

     Args:
         item_class: Class of items this container is allowed to contain.
     """

     def __init__(self, item_class):
         self.__item_class = item_class

     def _handle_item_addition(self, item, container):
         """Do all the generic work to add item to container.

         Must be called after item has been assigned to specific container, so
         that presence checks during addition pass.
         """
         # Make sure we're not adding item which already belongs to other
         # container
         if item._container:
             raise ItemAlreadyAssignedError(item)
         item._container = container
         fit = item._fit
         if fit is not None:
             for subitem in self.__subitem_iter(item):
                 msgs = MsgHelper.get_item_added_msgs(subitem)
                 fit._publish_bulk(msgs)
                 subitem._load()

     def _handle_item_removal(self, item):
         """Do all the generic work to remove item to container.

         Must be called before item has been removed from specific container, so
         that presence checks during removal pass.
         """
         fit = item._fit
         for subitem in self.__subitem_iter(item):
             subitem._unload()
             if fit is not None:
                 msgs = MsgHelper.get_item_removed_msgs(subitem)
                 fit._publish_bulk(msgs)
         item._container = None

     def __subitem_iter(self, item):
         """Iterate through passed item and its child items."""
         yield item
         # Skip autoloaded items because they are handled by loading or unloading
         # of parent item
         for child_item in item._child_item_iter(skip_autoitems=True):
             yield child_item

     def _check_class(self, item, allow_none=False):
         """Check if class of passed item corresponds to our expectations.

         Args:
             item: Item which should be checked.
             allow_none (optional): Define if None as item is fine or not. By
                 default, it is not.

         Raises:
             TypeError: If item class check fails.
         """
         if isinstance(item, self.__item_class):
             return
         if item is None and allow_none is True:
             return
         msg = 'expected {} instance{}, received {} instead'.format(
             self.__item_class.__qualname__,
             'or None' if allow_none is True else '',
             type(item).__qualname__)
         raise TypeError(msg)

 */
