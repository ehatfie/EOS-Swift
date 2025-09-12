//
//  Skill.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

class Skill: ImmutableStateMixin {
  var level: Int {
    get {
      _level
    }
    set {
      let oldLevel = _level
      guard newValue != oldLevel else {
        return
      }
      _level = newValue
      //self.attrs.overrdieValueMayChange(AttrId.skill_level)
    }
  }
  
  private var _level: Int
  
  //let modifierDomain: ModDomain = .character
  
  init(typeId: Int64, level: Int = 0) {
    self._level = level
    // self.attrs.setOverrideCallback
    super.init(typeId: typeId, state: .offline)
    
    self.modifierDomain = .character
    self.ownerModifiable = false
    self.solsysCarrier = nil
  }
}
