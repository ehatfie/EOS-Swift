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

  // keyed by carrier item (Ship), stores projector items
  var carrierProjectors: KeyedStorage<BaseItemMixin, BaseItemMixin> = KeyedStorage()
  var carrierlessProjectors: Set<Projector> = []
  // keyed by projector item, stores target items
  var projectorTargets: KeyedStorage<BaseItemMixin, BaseItemMixin> = KeyedStorage()
  // keyed by target item, stores projector items
  var targetProjectors: KeyedStorage<BaseItemMixin, BaseItemMixin> = KeyedStorage()

  init() { }

  func getProjectorTargets(projector: BaseItemMixin) -> Set<BaseItemMixin> {
    return self.projectorTargets.dictionary[projector, default: []]
  }

  public func getTargetProjectors(targetItem: any BaseItemMixinProtocol) -> Set<BaseItemMixin> {
    guard let item = targetItem as? BaseItemMixin else { return [] }
    return self.targetProjectors.dictionary[item, default: []]
  }

  func getCarrierProjectors(carrierItem: any BaseItemMixinProtocol) -> Set<BaseItemMixin> {
    guard let item = carrierItem as? BaseItemMixin else { return [] }
    return self.carrierProjectors.dictionary[item, default: []]
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
      return
    }

    self.carrierProjectors.addDataEntry(key: carrierItem, data: item)
  }

  func unregisterProjector(projector: Projector) {
    print("PR - unregisterProjector()")
    let item = projector.item
    self.projectors.remove(projector)

    guard let carrierItem = item.solsysCarrier else {
      print("++ no solsysCarrier")
      self.carrierlessProjectors.remove(projector)
      return
    }
    self.carrierProjectors.removeDataEntry(key: carrierItem, data: item)
  }

  func applyProjector(projector: any BaseItemMixinProtocol, targetItems: [any BaseItemMixinProtocol]) {
    print("PR - applyProjector()")
    guard let projectorItem = projector as? BaseItemMixin else { return }
    self.projectorTargets.addDataSet(key: projectorItem, dataSet: targetItems.compactMap { $0 as? BaseItemMixin })

    for targetItem in targetItems.compactMap({ $0 as? BaseItemMixin }) {
      self.targetProjectors.addDataEntry(key: targetItem, data: projectorItem)
    }
  }

  func unapplyProjector(projector: any BaseItemMixinProtocol, targetItems: [any BaseItemMixinProtocol]) {
    print("PR - unapplyProjector()")
    guard let projectorItem = projector as? BaseItemMixin else { return }
    self.projectorTargets.removeDataSet(key: projectorItem, dataSet: targetItems.compactMap { $0 as? BaseItemMixin })

    for targetItem in targetItems.compactMap({ $0 as? BaseItemMixin }) {
      self.targetProjectors.removeDataEntry(key: targetItem, data: projectorItem)
    }
  }

  func registerSolsysItem(solsysItem: Ship) {
    print("PR - registerSolsysItem()")
    var toActivate: Set<Projector> = []

    for projector in self.carrierlessProjectors {
      guard let itemCarrier = projector.item.solsysCarrier else { continue }
      if itemCarrier == solsysItem {
        toActivate.insert(projector)
      }
    }

    if !toActivate.isEmpty {
      self.carrierlessProjectors.subtract(toActivate)
      self.carrierProjectors.addDataSet(key: solsysItem, dataSet: toActivate.map { $0.item })
    }
  }

  func unregisterSolsysItem(solsysItem: Ship) {
    print("PR - unregisterSolsysItem()")
    // Move items back to carrierless; full Projector reconstruction requires
    // tracking effects per item which is not currently done here.
    self.carrierProjectors.dictionary.removeValue(forKey: solsysItem)
  }
}
