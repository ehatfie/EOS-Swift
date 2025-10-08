//
//  BaseResourceRegister.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//


public protocol BaseResourceRegisterProtocol: BaseStatsRegisterProtocol {
  var used: Double { get }
  var output: Double { get }
  var users: Set<AnyHashable> { get } // any BaseItemMixinProtocol ??
}

// TODO: Move
public protocol EffectsSubscriberProtocol {
  func handleEffectsStarted(message: EffectsStarted)
  func handleEffectsStopped(message: EffectsStopped)
  
  func notify(message: any Message)
}

extension EffectsSubscriberProtocol {
  public func notify(message: any Message) {
    switch message {
    case let m as EffectsStarted:
      handleEffectsStarted(message: m)
    case let m as EffectsStopped:
      handleEffectsStopped(message: m)
    default: break
    }
  }
}
