//
//  StateMixin.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//
//

protocol MutableStateMixinProtocol: BaseItemMixinProtocol {
  var state: StateI { get set }
}

extension MutableStateMixinProtocol {
  var state: StateI {
    return _state
  }
}


protocol ImmutableStateMixinProtocol: BaseItemMixinProtocol {
  var state: StateI { get }
}

extension ImmutableStateMixinProtocol {
  var state: StateI {
    get {
      return _state
    }
    set {
      return
    }
    
  }
}

public class ImmutableStateMixin: BaseItemMixin {
  public override var _state: StateI {
    set {
      return
    }
    get {
      return super._state
    }
  }
}

public class MutableStateMixin: BaseItemMixin {
  public override var _state: StateI {
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
        let iterator = self.childItemIterator(skipAutoItems: false)
        for childItem in iterator where childItem is ContainerStateMixin{
          let otherUpdateMessages = MessageHelper.getItemStateUpdateMessages(
            item: childItem as! ContainerStateMixin,
            oldState: oldState,
            newState: newValue
          )
          messages.append(contentsOf: otherUpdateMessages)
//            if let foo = childItem as? ContainerStateMixin {
//              
//            }
        }
        
        fit.publishBulk(messages: messages)
      }
    }
  }
}


/// Items based on this class inherit state from item which contains them.
public class ContainerStateMixin: BaseItemMixin {
  
  public override var _state: StateI {
    set {
      return
    }
    get {
      if let container = self.container as? any BaseItemMixinProtocol {
        return container._state
      }
      return .offline
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
