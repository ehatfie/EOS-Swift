//
//  FitSet.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 11/4/25.
//

/// Unordered container for fits. Implements set-like interface.
public class FitSet {
  public let solarSystem: SolarSystem
  public var fits: [Fit] = []
  
  public init(solarSystem: SolarSystem) {
    self.solarSystem = solarSystem
  }
  
  // MARK: - Modifying methods
  
  /// Add fit to the container.
  /// Args: fit: Fit to add.
  public func add(fit: Fit) {
    guard fit.solarSystem != nil else {
      // raise ValueError(fit)
      return
    }
    
    self.fits.append(fit)
    fit.solarSystem = self.solarSystem
    self.solarSystem.calculator.handleFitAdded(fit: fit)
    fit.loadItems()
  }
  
  /// Remove fit from the container.
  /// Args fit: Fit to remove.
  ///  Raises: KeyError: If fit cannot be removed from the container (e.g. it doesn't belong to it).
  public func remove(fit: Fit) {
//    guard self.fits.contains(where: { $0 == fit }) {
//      return
//    }
    
    self.handleFitRemoval(fit: fit)
  }
  
  public func handleFitRemoval(fit: Fit) {
    fit.unloadItems()
    self.solarSystem.calculator.handleFitRemoved(fit: fit)
    // self.set.remove(fit)
    fit.solarSystem = nil
  }
  
  /// Remove everything from the container.
  public func clear() {
    /*
     for fit in set(self.__set):
         self.__handle_fit_removal(fit)
     */
    
    for fit in self.fits {
      self.handleFitRemoval(fit: fit)
    }
  }
  
  public func contains(fit: Fit) -> Bool {
    return false// fit in self.__set
  }
  
  public func len() -> Int {
    return self.fits.count
  }
}

/*
 class FitSet:
     # Non-modifying methods
     def __iter__(self):
         return iter(self.__set)

     # Auxiliary methods
     def __repr__(self):
         return repr(self.__set)

 */
