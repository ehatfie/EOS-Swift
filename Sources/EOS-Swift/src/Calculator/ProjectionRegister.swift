//
//  ProjectionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

/// Keeps track of various projection-related connections.
class ProjectionRegister {
  var projectors: Set<BaseItemMixin> = []
  
  var carrierProjectors: KeyedStorage = KeyedStorage()
  var carrierlessProjectors: Set<BaseItemMixin> = []
  var projectorTargets: KeyedStorage = KeyedStorage()
  var targetProjectors: KeyedStorage = KeyedStorage()

  init() { }
  
  func getProjectorTargets(projector: BaseItemMixin) -> Set<AnyHashable> {
    return self.projectorTargets.dictionary[projector, default: []]
  }
  
  func getTargetProjectors(targetItem: any BaseItemMixinProtocol) -> Set<AnyHashable> {
    return self.targetProjectors.dictionary[targetItem as! BaseItemMixin, default: []]
  }
  
  func getCarrierProjectors(carrierItem: any BaseItemMixinProtocol) -> Set<AnyHashable> {
    return self.carrierProjectors.dictionary[carrierItem as! BaseItemMixin, default: []]
  }
  
  func getProjectors() -> Set<BaseItemMixin> {
    return self.projectors
  }
  
  func registerProjector(projector: any BaseItemMixinProtocol) {
    print("PR - registerProjector()")
    guard let item = projector as? BaseItemMixin else {
      print("++ no item")
      return
    }
    
    guard let carrierItem = item.solsysCarrier else {
      print("++ no solsysCarrier")
      self.carrierlessProjectors.insert(item)
      return
    }

    self.carrierProjectors.addDataEntry(key: carrierItem as AnyHashable, data: item)
    //let carrierItem = projector.itemType
  }
  
  func unregisterProjector(projector: any BaseItemMixinProtocol) {
    print("PR - unregisterProjector()")
    guard let item = projector as? BaseItemMixin else {
      print("++ no item")
      return
    }
    
    self.projectors.remove(item)
    
    guard let carrierItem = item.solsysCarrier else {
      print("++ no solsysCarrier")
      self.carrierlessProjectors.remove(item)
      return
    }
    self.carrierProjectors.removeDataEntry(key: carrierItem as AnyHashable, data: item)
  }
  
  func applyProjector(projector: any BaseItemMixinProtocol, targetItems: [any BaseItemMixinProtocol]) {
    print("PR - applyProjector()")
    self.projectorTargets.addDataSet(key: projector as! AnyHashable, dataSet: targetItems as! [AnyHashable])
    
    for targetItem in targetItems {
      self.targetProjectors.addDataEntry(key: targetItem as! BaseItemMixin, data: projector as! BaseItemMixin)
    }
  }
  
  func unapplyProjector(projector: any BaseItemMixinProtocol, targetItems: [any BaseItemMixinProtocol]) {
    print("PR - unapplyProjector()")
    self.projectorTargets.removeDataSet(key: projector as! AnyHashable, dataSet: targetItems as! [AnyHashable])
    
    for targetItem in targetItems {
      self.targetProjectors.removeDataEntry(key: targetItem as! BaseItemMixin, data: projector as! BaseItemMixin)
    }
  }
  
  func registerSolsysItem(solsysItem: Ship) {
    print("PR - registerSolsysItem()")
    var projectors: Set<BaseItemMixin> = []
    
    for projector in self.carrierlessProjectors {
      // if projector.item._solsys_carrier is solsys_item:
      guard let itemCarrier = projector.solsysCarrier else {
        continue
      }
      
      if itemCarrier == solsysItem {
        projectors.insert(projector)
      }
    }
    
    if !projectors.isEmpty {
      self.carrierlessProjectors.subtract(projectors)
      self.carrierProjectors.addDataSet(key: solsysItem, dataSet: Array(projectors) as! [AnyHashable])
    }
  }
  
  func unregisterSolsysItem(solsysItem: Ship) {
    print("PR - unregisterSolsysItem()")
    var projectors = self.carrierProjectors.dictionary[solsysItem, default: []] as! Set<BaseItemMixin>
    
    if !projectors.isEmpty {
      for projector in projectors {
        self.carrierlessProjectors.insert(projector)
      }
      self.carrierProjectors.removeDataSet(key: solsysItem, dataSet: Array(projectors) as! [AnyHashable])
    }
  }
}
