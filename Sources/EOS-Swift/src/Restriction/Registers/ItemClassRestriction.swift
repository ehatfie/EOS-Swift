//
//  ItemClassRestriction.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/18/25.
//

struct ItemClassErrorData {
  let itemClass: (any BaseItemMixinProtocol).Type
  let allowedClass: (any BaseItemMixinProtocol).Type
}

class ItemClassRestriction: BaseRestrictionProtocol {
  var restrictionType: Restriction = .item_class
  
  var fit: Fit
  
  init(fit: Fit) {
    self.fit = fit
  }
  
  func validate() throws {
    var taintedItems: [AnyHashable: ItemClassErrorData] = [:]
    // TODO
    // _loaded_item_iter(skip_autoitems=True):
    
  }
}
