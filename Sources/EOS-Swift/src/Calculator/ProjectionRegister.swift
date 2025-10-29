//
//  ProjectionRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

struct Projector: Hashable {
  static func == (lhs: Projector, rhs: Projector) -> Bool {
    return lhs.effect == rhs.effect && lhs.item == rhs.item
  }
  
  let item: BaseItemMixin
  let effect: Effect
}

/// Keeps track of various projection-related connections.
class ProjectionRegister {
  var projectors: Set<Projector> = []
  
  var carrierProjectors: KeyedStorage = KeyedStorage()
  var carrierlessProjectors: Set<Projector> = []
  var projectorTargets: KeyedStorage = KeyedStorage()
  var targetProjectors: KeyedStorage = KeyedStorage()

  init() { }
  
  func getProjectorTargets(projector: BaseItemMixin) -> Set<AnyHashable> {
    return self.projectorTargets.dictionary[projector, default: []]
  }
  
  public func getTargetProjectors(targetItem: any BaseItemMixinProtocol) -> Set<AnyHashable> {
    return self.targetProjectors.dictionary[targetItem as! BaseItemMixin, default: []]
  }
  
  func getCarrierProjectors(carrierItem: any BaseItemMixinProtocol) -> Set<AnyHashable> {
    return self.carrierProjectors.dictionary[carrierItem as! BaseItemMixin, default: []]
  }
  
  func getProjectors() -> Set<Projector> {
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
      //self.carrierlessProjectors.insert(Projector(item: item, effect: <#T##Effect#>))
      return
    }

    self.carrierProjectors.addDataEntry(key: carrierItem as AnyHashable, data: item)
    //let carrierItem = projector.itemType
  }
  
  func unregisterProjector(projector: Projector) {
    print("PR - unregisterProjector()")
    guard let item = projector.item as? BaseItemMixin else {
      print("++ no item")
      return
    }
    
    self.projectors.remove(projector)
    
    guard let carrierItem = item.solsysCarrier else {
      print("++ no solsysCarrier")
      self.carrierlessProjectors.remove(projector)
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
    var projectors: Set<Projector> = []
    
    for projector in self.carrierlessProjectors {
      // if projector.item._solsys_carrier is solsys_item:
      guard let itemCarrier = projector.item.solsysCarrier else {
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
    var projectors = self.carrierProjectors.dictionary[solsysItem, default: []] as! Set<Projector>
    
    if !projectors.isEmpty {
      for projector in projectors {
        self.carrierlessProjectors.insert(projector)
      }
      self.carrierProjectors.removeDataSet(key: solsysItem, dataSet: Array(projectors) as! [AnyHashable])
    }
  }
}
