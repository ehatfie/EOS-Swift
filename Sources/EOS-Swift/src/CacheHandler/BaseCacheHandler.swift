//
//  BaseCacheHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

protocol BaseCacheHandlerProtocol {
  func getType(typeId: Int64) -> ItemType?
  func getAttribute(attributeId: AttrId)
  func getEffect(effectId: EffectId)
  func getBuffTemplates(buffId: Int64)
  func getFingerprint() -> String
  func updateCache(eveObjects: Any, fingerprint: Any)
}
