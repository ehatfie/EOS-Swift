//
//  DataSource.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/5/25.
//



protocol DataSource {
  // might want to return a model?
  func getAttribute(typeId: AttrId) -> MockAttribute?
}
