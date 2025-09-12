//
//  Targetable.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


protocol BaseTargetableMixinProtocol {
  func getEffectTarget(effectIds: [Int64]) -> Any?
}

class BaseTargetableMixin: BaseTargetableMixinProtocol {
  func getEffectTarget(effectIds: [Int64]) -> Any? {
    return nil
  }
}

protocol SingleTargetableMixinProtocol: BaseTargetableMixinProtocol {
  var target: Any? { get }
}
