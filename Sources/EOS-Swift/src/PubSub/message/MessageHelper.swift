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
    let states = State.allCases.filter { $0 <= item._state }
    messages.append(StatesActivated(item: item, states: Set<State>(states)))
    return messages
  }
  
  static func getItemRemovedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    let states = State.allCases.filter { $0 <= item._state }
    messages.append(StatesDeactivated(item: item, states: Set<State>(states)))
    messages.append(ItemRemoved(fit: nil, item: item))
    return messages
  }
  
  static func getItemLoadedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    messages.append(ItemLoaded(fit: nil, item: item))
    let states = State.allCases.filter { $0 <= item._state }
    messages.append(StatesActivatedLoaded(item: item, states: Set<State>(states)))
    //msgs.extend(MsgHelper.get_effects_status_update_msgs(item))
    messages.append(contentsOf: [])
    return messages
  }
  static func getItemUnloadedMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var messages: [any Message] = []
    /*
     """Generate messages about unloaded item."""
     msgs = []
     # Effects
     running_effect_ids = item._running_effect_ids
     if running_effect_ids:
         # Unapply effects before stopping them
         tgt_getter = getattr(item, '_get_effects_tgts', None)
         if tgt_getter:
             effects_tgts = tgt_getter(running_effect_ids)
             for effect_id, tgt_items in effects_tgts.items():
                 msgs.append(EffectUnapplied(item, effect_id, tgt_items))
         # Stop effects
         # Copy running effect IDs container, because we clear it on the next
         # line but it will be processed by message subscribers much later
         msgs.append(EffectsStopped(item, copy(running_effect_ids)))
         running_effect_ids.clear()
     # States
     states = {s for s in State if s <= item.state}
     msgs.append(StatesDeactivatedLoaded(item, states))
     # Item
     msgs.append(ItemUnloaded(item))
     */
//    messages.append(ItemUnloaded(fit: nil, item: item))
//    let states = State.allCases.filter { $0 <= item._state }
//    messages.append(StatesDeactivatedLoaded(item: item, states: Set<State>(states)))
    return messages
  }
  
  static func getItemStateUpdateMessages(
    item: any BaseItemMixinProtocol,
    oldState: State,
    newState: State
  ) -> [any Message] {
    var messages: [any Message] = []
    return messages
    /*
     """Generate messages about changed item state."""
     msgs = []
     # State switching upwards
     if new_state > old_state:
         states = {s for s in State if old_state < s <= new_state}
         msgs.append(StatesActivated(item, states))
         if item._is_loaded:
             msgs.append(StatesActivatedLoaded(item, states))
     # State switching downwards
     else:
         states = {s for s in State if new_state < s <= old_state}
         if item._is_loaded:
             msgs.append(StatesDeactivatedLoaded(item, states))
         msgs.append(StatesDeactivated(item, states))
     # Effects
     if item._is_loaded:
         msgs.extend(MsgHelper.get_effects_status_update_msgs(item))
     */
  }
  /// Generate messages about changed effect statuses.
  /// Besides generating messages, it actually updates item's set of effects
  /// which are considered as running.
  static func getEffectsStatusUpdateMessages(item: any BaseItemMixinProtocol) -> [any Message] {
    var newRunningEffectIds: Set<EffectId> = []
    let effectStatus = EffectStatusResolver.resolveEffectsStatus(item: item)
    for (effectId, status) in effectStatus {
      if status {
        newRunningEffectIds.insert(effectId)
      }
    }
   
    let startIds = newRunningEffectIds.subtracting(item.runningEffectIds)
    let stopIds = item.runningEffectIds.subtracting(newRunningEffectIds)
    
    var messages: [any Message] = []
    if !startIds.isEmpty {
      
    }
    /*
     # Set of effects which should be running according to new conditions
     new_running_effect_ids = set()
     effects_status = EffectStatusResolver.resolve_effects_status(item)
     for effect_id, status in effects_status.items():
         if status:
             new_running_effect_ids.add(effect_id)
     start_ids = new_running_effect_ids.difference(item._running_effect_ids)
     stop_ids = item._running_effect_ids.difference(new_running_effect_ids)
     msgs = []
     if start_ids:
         item._running_effect_ids.update(start_ids)
         # Start effects
         msgs.append(EffectsStarted(item, start_ids))
         # Apply effects to targets
         tgt_getter = getattr(item, '_get_effects_tgts', None)
         if tgt_getter:
             effects_tgts = tgt_getter(start_ids)
             for effect_id, tgt_items in effects_tgts.items():
                 msgs.append(EffectApplied(item, effect_id, tgt_items))
     if stop_ids:
         # Unapply effects from targets
         tgt_getter = getattr(item, '_get_effects_tgts', None)
         if tgt_getter:
             effects_tgts = tgt_getter(stop_ids)
             for effect_id, tgt_items in effects_tgts.items():
                 msgs.append(EffectUnapplied(item, effect_id, tgt_items))
         # Stop effects
         msgs.append(EffectsStopped(item, stop_ids))
         item._running_effect_ids.difference_update(stop_ids)
     */
    return messages
  }

}
