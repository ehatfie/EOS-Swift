//
//  Execptions.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/17/25.
//


protocol EosError: Error {
  
}

/// All restriction service exceptions are based on this class
class RestrictionServiceError: EosError, @unchecked Sendable {
  
}

/// Raised if validation on restriction level fails.
final class RestrictionValidationError: RestrictionServiceError, @unchecked Sendable {
  var data: Any
  
  init(data: Any) {
    self.data = data
  }
}

/// Raised if service-wide validation fails.
class ValidationError: RestrictionServiceError, @unchecked Sendable {
  var data: Any
  
  init(data: Any) {
    self.data = data
  }
}


