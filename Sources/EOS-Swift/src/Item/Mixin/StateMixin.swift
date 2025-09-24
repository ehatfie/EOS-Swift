//
//  StateMixin.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//
//

protocol MutableStateMixinProtocol: BaseItemMixinProtocol {
  var state: State { get set }
}

extension MutableStateMixinProtocol {
  var state: State {
    return _state
  }
}


protocol ImmutableStateMixinProtocol: BaseItemMixinProtocol {
  var state: State { get }
}

extension ImmutableStateMixinProtocol {
  var state: State {
    get {
      return _state
    }
    set {
      return
    }
    
  }
}

class ImmutableStateMixin: BaseItemMixin {
  override var _state: State {
    set {
      return
    }
    get {
      return super._state
    }
  }
}

class MutableStateMixin: BaseItemMixin {
  override var _state: State {
    get {
      super._state
    }
    set {
      let oldState = self._state
      if newValue == oldState {
        return
      }
      
      super._state = newValue
      if let fit = super.fit {
        // update via messages?
        var messages = [any Message]()

        let stateUpdateMessages = MessageHelper.getItemStateUpdateMessages(
          item: self,
          oldState: oldState,
          newState: newValue
        )
        messages.append(contentsOf: stateUpdateMessages)
        if let iterator = self.childItemIterator(skipAutoItems: false) {
          for childItem in iterator where childItem is ContainerStateMixin{
            let otherUpdateMessages = MessageHelper.getItemStateUpdateMessages(
              item: childItem as! ContainerStateMixin, oldState: oldState, newState: newValue)
            messages.append(contentsOf: otherUpdateMessages)
//            if let foo = childItem as? ContainerStateMixin {
//              
//            }
          }
        }
        fit.publishBulk(messages: messages)
      }
    }
  }
}


/// Items based on this class inherit state from item which contains them.
class ContainerStateMixin: BaseItemMixin {
  override var _state: State {
    set {
      return
    }
    get {
      return .active
//      if let foo = container {
//        return bar.state
//      }
      //self.container?.state ?? .offline
    }
  }
}


/*

 class ContainerStateMixin(BaseItemMixin):
     """"""

     @property
     def state(self):
         try:
             return self._container.state
         except AttributeError:
             return None

 */

// NOTE: Maybe BaseItemMixin can be the protocol?
