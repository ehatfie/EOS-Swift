//
//  BaseCacheHandler.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

public protocol BaseCacheHandlerProtocol: Sendable {
  func getType(typeId: Int64) -> ItemType?
  func getAttribute(attributeId: AttrId)
  func getEffect(effectId: EffectId)
  func getBuffTemplates(buffId: Int64)
  func getFingerprint() -> String
  func updateCache(
    types: [ItemType],
    attributes: [Attribute],
    effects: [Effect],
    buffTemplates: [BuffTemplate], fingerprint: String
  )
}
