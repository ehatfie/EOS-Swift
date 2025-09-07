//
//  BaseWarfareBuff.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//

class WarfareBuffEffect: Effect {
  var friendlyOnly: Bool? {
    nil
  }
}

class ModuleBonusWarfareLinkArmor: WarfareBuffEffect {
  override var friendlyOnly: Bool? {
    return true
  }
}

class ModuleBonusWarfareLinkInfo: WarfareBuffEffect {
  override var friendlyOnly: Bool? {
    return true
  }
}

class ModuleBonusWarfareLinkSkirmish: WarfareBuffEffect {
  override var friendlyOnly: Bool? {
    return true
  }
}

class ModuleBonusWarfareLinkShield: WarfareBuffEffect {
  override var friendlyOnly: Bool? {
    return true
  }
}

class ModuleBonusWarfareLinkMining: WarfareBuffEffect {
  override var friendlyOnly: Bool? {
    return true
  }
}
