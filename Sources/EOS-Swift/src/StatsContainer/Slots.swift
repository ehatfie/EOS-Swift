//
//  Slots.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/6/25.
//


public struct SlotStats {
  public let used: Int
  public let total: Int
  
  public init(used: Int, total: Int) {
    self.used = used
    self.total = total
  }
}
