//
//  LoadedItemRestrictionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//

struct LoadedItemErrorData {
  
}

class LoadedItemRestriction: BaseRestrictionProtocol, FitHaving {
  var restrictionType: Restriction = .loaded_item
  
  var fit: Fit
  
  init(fit: Fit) {
    self.fit = fit
  }
  
  func validate() throws {
    var taintedItems: [AnyHashable: LoadedItemErrorData] = [:]
    
    
  }
  
}
