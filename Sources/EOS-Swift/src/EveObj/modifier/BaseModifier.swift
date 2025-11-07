//
//  BaseModifier.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/15/25.
//

/// Define base functionality for all modifier types.
/// Modifiers are part of effects; one modifier describes one modification when it should be applied, on which items, how to apply it, and so on.
protocol BaseModifierProtocol: AnyObject, Equatable, Hashable {
  var affecteeFilter: ModAffecteeFilter? { get }
  var affecteeFilterExtraArg: Int64? { get }
  var affecteeDomain: ModDomain? { get }
  var affecteeAtributeId: Int64? { get }

  func getModification(affectorItem: any BaseItemMixinProtocol) -> GetModResponse?

  func validateBase() -> Bool
  func validateCommon() -> Bool
  func validateAffecteeFilterItem() -> Bool
  func validateAffecteeFilterDomain() -> Bool
  func validateAffecteeFilterDomainGroup() -> Bool
  func validateAffecteeFilterDomainSkillRequirement() -> Bool
  func validateAffecteeFilterOwnerSkillRequirement() -> Bool
}

extension BaseModifierProtocol where Self: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hashValue == rhs.hashValue
    //lhs.affecteeDomain == rhs.affecteeDomain
    
  }
}

extension BaseModifierProtocol where Self: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(affecteeFilter)
    hasher.combine(affecteeFilterExtraArg)
    hasher.combine(affecteeDomain)
    hasher.combine(affecteeAtributeId)
  }
}



extension BaseModifierProtocol {
  
  private var nilAffecteeFilterExtraArg: Bool {
    return self.affecteeFilterExtraArg == nil
  }

  func validateBase() -> Bool {
    let validationResult: Bool
    switch self.affecteeFilter {
    case .item: validationResult = self.validateAffecteeFilterItem()
    case .domain: validationResult = self.validateAffecteeFilterDomain()
    case .domain_group: validationResult = self.validateAffecteeFilterDomainGroup()
    case .domain_skillrq: validationResult = self.validateAffecteeFilterDomainSkillRequirement()
    case .owner_skillrq: validationResult = self.validateAffecteeFilterOwnerSkillRequirement()
    case .none:
      return false
    }
    return validateCommon() && validationResult
  }
  
  func validateCommon() -> Bool {
    guard let affecteeFilter else { return false }
    let validModAffecteeFilter = ModAffecteeFilter.allCases.contains(affecteeFilter)
    let validModDomain = ModDomain.allCases.contains(self.affecteeDomain!)
    return validModAffecteeFilter && validModDomain
  }
  
  func validateAffecteeFilterItem() -> Bool {
    let validModDomain = ModDomain.allCases.contains(self.affecteeDomain!)
    return nilAffecteeFilterExtraArg && validModDomain
  }
  
  func validateAffecteeFilterDomain() -> Bool {
    let expectedModDomains: [ModDomain] = [.me, .character, .ship, .target]
    let validModDomain = expectedModDomains.contains(self.affecteeDomain!)
    return nilAffecteeFilterExtraArg && validModDomain
  }
  
  func validateAffecteeFilterDomainGroup() -> Bool {
    let expectedModDomains: [ModDomain] = [.me, .character, .ship, .target]
    let validModDomain = expectedModDomains.contains(self.affecteeDomain!)
    return !nilAffecteeFilterExtraArg && validModDomain
  }
  
  func validateAffecteeFilterDomainSkillRequirement() -> Bool {
    let expectedModDomains: [ModDomain] = [.me, .character, .ship, .target]
    let validModDomain = expectedModDomains.contains(self.affecteeDomain!)
    return !nilAffecteeFilterExtraArg && validModDomain
  }
  
  func validateAffecteeFilterOwnerSkillRequirement() -> Bool {
    let validModDomain = self.affecteeDomain == .character
    return !nilAffecteeFilterExtraArg && validModDomain
  }
}
