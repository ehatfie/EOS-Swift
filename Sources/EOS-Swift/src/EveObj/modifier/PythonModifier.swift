//
//  PythonModifier.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//


protocol BasePythonModifierProtocol: BaseModifierProtocol {
  func reviseMessageTypes()
  func reviseModification(message: Any, affectorItem: any BaseItemMixinProtocol) -> Bool
}
