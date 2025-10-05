//
//  SolarSystem.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/11/25.
//

protocol SolarSystemProtocol {

}

class MockSolarSystem: SolarSystemProtocol {

}

public class SolarSystem: MaybeFitHaving {
  var source: Source? {
    get {
      return self.Source
    }
    set {
      let oldSource = self.Source
      if newValue == oldSource {
        return
      }

      if let source = oldSource {
        for fit in self.fits {
          fit.unloadItems()
        }
      }

      self.Source = newValue

      if let source = self.Source {
        for fit in self.fits {
          fit.loadItems()
        }
      }
    }
  }

  private var Source: Source?
  weak public var fit: Fit?
  var calculator: CalculationService!

  var fits: [Fit] {
    return []
  }

  @MainActor
  init(source: SourceManager?) {
    self.source = nil
    self.calculator = CalculationService(solarSystem: self)

    self.source = SourceManager.defaultValue
  }
}

public class SourceManager: @unchecked Sendable {
  @MainActor
  static var defaultValue: Source? {
    SourceManager.shared.defaultSource
  }
  @MainActor public static var shared: SourceManager = SourceManager()
  var sources: [String: Source] = [:]
  
  var defaultSource: Source? = nil

  /// Add source to source manager
  /// Adding includes initializing all facilities hidden behind name 'source'.
  /// After source has been added, it is accessible with alias.
  nonisolated(unsafe)
    public func add(
      alias: String,
      dataHandler: any DataHandlerProtocol,
      cacheHandler: any BaseCacheHandlerProtocol,
      makeDefault: Bool = false
    ) async
  {
    if await self.sources.contains(where: { $0.key == alias }) {
      // raise ExistingSourceError(alias)
    }

    //Compare fingerprints from data and cache
    let cacheFP = await cacheHandler.getFingerprint()
    let dataVersion = dataHandler.getVersion()
    let currentFP = await self.formatFingerprint(dataVersion: dataVersion)

    // If data version is corrupt or fingerprints mismatch, update cache
    if dataVersion == nil || cacheFP != currentFP {
      if dataVersion == nil {
        print("++ data version is nil, updating cache")
      } else {
        print("++ fingerprint mismatch, updating cache")
      }
    }
    
    // Generate eve objects and cache them, as generation takes significant amount of time
    let eveObjects = await EveObjectBuilder.run(dataHandler: dataHandler)
    let attributes = eveObjects.0
    let effects = eveObjects.1
    let types = eveObjects.2
    let buffTemplates = eveObjects.3
    
    await cacheHandler.updateCache(types: types, attributes: attributes, effects: effects, buffTemplates: buffTemplates, fingerprint: currentFP)
    
    //Finally, add record to list of sources
    let source = Source(alias: alias, cacheHandler: cacheHandler)
    self.sources[alias] = source
    if makeDefault {
      self.defaultSource = source
    }
  }

  /*
   @staticmethod
       def __format_fingerprint(data_version):
           return '{}_{}'.format(data_version, eos_version)
   */

  func formatFingerprint(dataVersion: String?) -> String {
    // TODO: move
    let eosVersion = "0.0.1"
    return "\(dataVersion ?? "")_\(eosVersion)"
  }
}

struct Source: Equatable, Sendable {
  static func == (lhs: Source, rhs: Source) -> Bool {
    return lhs.alias == rhs.alias
  }

  let alias: String
  let cacheHandler: any BaseCacheHandlerProtocol
}
