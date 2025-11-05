//
//  MessageHelper.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/9/25.
//


/// Assists with generation of messages.
class MessageHelper {
  static func getItemAddedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    messages.append(ItemAdded(fit: nil, item: item))
    // states = {s for s in State if s <= item.state}
    let states = StateI.allCases.filter { $0 <= item._state }
    messages.append(StatesActivated(item: item, states: Set<StateI>(states)))
    return messages
  }
  
  static func getItemRemovedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    let states = StateI.allCases.filter { $0 <= item._state }
    messages.append(StatesDeactivated(item: item, states: Set<StateI>(states)))
    messages.append(ItemRemoved(fit: nil, item: item))
    return messages
  }
  
  static func getItemLoadedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    messages.append(ItemLoaded(fit: nil, item: item))
    let states = StateI.allCases.filter { $0 <= item._state }
    messages.append(StatesActivatedLoaded(item: item, states: Set<StateI>(states)))
    messages.append(contentsOf: getEffectsStatusUpdateMessages(item: item))
    return messages
  }
  
  ///Generate messages about unloaded item.
  static func getItemUnloadedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
   
    // Effects
    let runningEffectIds = item.runningEffectIds
    if !runningEffectIds.isEmpty {
      // unapply effects before stoppoing them
      
      if let foo = item as? BaseTargetableMixinProtocol {
        let effectTargets = foo.getEffectTargets(effectIds: Array(runningEffectIds))
        
        for (effectId, targetItems) in effectTargets ?? [] {
          messages.append(
            EffectUnapplied(item: item, effectId: effectId, targetItems: targetItems)
          )
        }
      }
      
      // Stop effects
      // Copy running effect IDs container, because we clear it on the next
      // line but it will be processed by message subscribers much later
      let runningEffectCopy = runningEffectIds
      messages.append(EffectsStopped(item: item, effectIds: runningEffectCopy))
      item.runningEffectIds.removeAll()
    }
    // States
    let states = StateI.allCases.filter({ $0 < item._state })
    messages.append(StatesDeactivatedLoaded(item: item, states: Set(states)))
    // Item
    messages.append(ItemUnloaded(item: item))
    return messages
  }
  
  /// Generate messages about changed item state.
  static func getItemStateUpdateMessages(
    item: any BaseItemMixinProtocol,
    oldState: StateI,
    newState: StateI
  ) -> [any Message] {
    // State switching upwards
    var messages: [any Message] = []
    // State switching upwards
    if newState > oldState {
      let states = Set(StateI.allCases.filter({ $0 <= newState && $0 > oldState }))
      messages.append(StatesActivated(item: item, states: states))
      
      if item.isLoaded {
        messages.append(StatesActivatedLoaded(item: item, states: states))
      }
    } else {
      // State switching downward
      let states = Set(StateI.allCases.filter({ $0 > newState && $0 <= oldState }))
      if item.isLoaded {
        messages.append(StatesDeactivated(item: item, states: states))
      }
    }
    
    // Effects
    if item.isLoaded {
      messages.append(contentsOf: getEffectsStatusUpdateMessages(item: item))
    }
    return messages

  }
  /// Generate messages about changed effect statuses.
  /// Besides generating messages, it actually updates item's set of effects
  /// which are considered as running.
  static func getEffectsStatusUpdateMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    print(":: getEffectsStatusUpdateMessages for \(item.typeId) \(item.itemType?.name) has \(item.typeEffects.count) typeEffects \(item.typeEffects)")
    // Set of effects which should be running according to new conditions
    var newRunningEffectIds: Set<Int64> = []
    let effectStatus = EffectStatusResolver.resolveEffectsStatus(item: item)
    for (effectId, status) in effectStatus {
      
      if status {
        newRunningEffectIds.insert(effectId)
      }
      print(":: checking effectId \(effectId) \(EffectId(rawValue: effectId)) status \(status) running \(newRunningEffectIds.count)")
    }
    
    let startIds = newRunningEffectIds.subtracting(item.runningEffectIds)
    let stopIds = item.runningEffectIds.subtracting(newRunningEffectIds)
    print(":: newRunningEffectIds \(newRunningEffectIds.count) startIds: \(startIds.count) stopIds: \(stopIds.count)")
    var messages: [any Message] = []
    if !startIds.isEmpty {
      item.runningEffectIds = item.runningEffectIds.union(startIds)
      // Start effects
      messages.append(EffectsStarted(item: item, effectIds: startIds))
      
      // Apply effects to targets
      if let foo = item as? BaseTargetableMixinProtocol {
        let results = foo.getEffectTargets(effectIds: Array(startIds))
        for (effectId, targetItems) in results ?? [] {
          messages.append(EffectApplied(item: item, effectId: effectId, targetItems: targetItems))
        }
      } else {
        print("no foo")
      }
    }
    
    if !stopIds.isEmpty {
      // Unapply effects from targets
      if let foo = item as? BaseTargetableMixinProtocol {
        let results = foo.getEffectTargets(effectIds: Array(stopIds))
        for (effectId, targetItems) in results ?? [] {
          messages.append(EffectUnapplied(item: item, effectId: effectId, targetItems: targetItems))
        }
      }
      // Stop effects
      messages.append(EffectsStopped(item: item, effectIds: stopIds))
      item.runningEffectIds.subtract(stopIds)
    }
    
    return messages
  }

}
