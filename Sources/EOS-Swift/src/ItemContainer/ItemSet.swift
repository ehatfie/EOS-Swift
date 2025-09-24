//
//  ItemSet.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//


protocol FitHaving: AnyObject {
  var fit: Fit { get }
}

protocol FitRelated: AnyObject {
  var parent: (any MaybeFitHaving)? { get }
}

protocol MaybeFitHaving: AnyObject {
  var fit: Fit? { get }
}


class ItemSet<T: BaseItemMixinProtocol>: ItemContainerBase<T>, FitRelated, MaybeFitHaving {
  weak var parent: (any MaybeFitHaving)?
  
  var set: Set<T> = []
  var containerOverride: (any ItemContainerBaseProtocol)? = nil
  
  /*
   parent: Object, to which this container is attached.
   item_class: Class of items this container is allowed to contain.
   container_override (optional): When this argument is set, its value will
               be assigned as container to all items being added.
   */
  
  init(parent: any MaybeFitHaving, containerOverride: Any?) {
    self.parent = parent
    super.init()
  }
  
  func add(item: T) {
    set.insert(item)
    
    let containerToUse = containerOverride ?? self
    try? self.handleItemAddition(item, container: containerToUse as! ItemContainerBase<BaseItemMixin>)
  }
  
  func remove(item: T) {
    let containerToUse = containerOverride ?? self
    try? self.handleItemAddition(item, container: containerToUse as! ItemContainerBase<BaseItemMixin>)
    
    set.remove(item)
  }
  
  func clear() {
    var items = set
    for item in items {
      self.handleItemRemoval(item)
      self.set.remove(item)
    }
  }
  
  func iterator() -> AnyIterator<T>{
    let values = set.map { $0 }
    var index = 0
    return AnyIterator {
      guard index < values.count else { return nil }
      defer { index += 1 }
      return values[index]
    }
  }
  
  func contains(item: T) -> Bool {
    return set.contains(item)
  }
  
  override func length() -> Int {
    return set.count
  }
  
  var fit: Fit? {
    return parent?.fit
  }
}
