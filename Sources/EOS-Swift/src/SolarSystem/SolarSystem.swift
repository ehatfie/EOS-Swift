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
      self.Source
    }
    set {
      let oldSource = self.source
      if newValue == oldSource {
        return
      }
      
      if let source = oldSource {
        for fit in self.fits {
          fit.unloadItems()
        }
      }
      
      self.source = newValue
      
      if let source = self.source {
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

  init(source: SourceManager?) {
    self.source = nil
    self.calculator = CalculationService(solarSystem: self)

    self.source = SourceManager.defaultValue
  }
}


public actor SourceManager: @unchecked Sendable {
  nonisolated(unsafe) static let defaultValue: Source? = nil
  @MainActor static var shared: SourceManager = SourceManager()
  var sources: [String: Source] = [:]

  /// Add source to source manager
  /// Adding includes initializing all facilities hidden behind name 'source'.
  /// After source has been added, it is accessible with alias.
  nonisolated(unsafe)
  func add(
    source: Source,
    alias: String,
    dataHandler: any DataHandlerProtocol,
    cacheHandler: any BaseCacheHandlerProtocol,
    makeDefault: Bool = false
  ) async {
    /*
     # Compare fingerprints from data and cache
     cache_fp = cache_handler.get_fingerprint()
     data_version = data_handler.get_version()
     current_fp = cls.__format_fingerprint(data_version)
     
     # If data version is corrupt or fingerprints mismatch, update cache
     if data_version is None or cache_fp != current_fp:
     if data_version is None:
     logger.info('data version is None, updating cache')
     else:
     msg = (
     'fingerprint mismatch: cache "{}", data "{}", '
     'updating cache'
     ).format(cache_fp, current_fp)
     logger.info(msg)
     
     # Generate eve objects and cache them, as generation takes
     # significant amount of time
     eve_objects = EveObjBuilder.run(data_handler)
     cache_handler.update_cache(eve_objects, current_fp)
     
     # Finally, add record to list of sources
     source = Source(alias=alias, cache_handler=cache_handler)
     cls._sources[alias] = source
     if make_default is True:
     cls.default = source
     */
    
    if await self.sources.contains(where: { $0.key == alias }) {
      // raise ExistingSourceError(alias)
    }
      
      //Compare fingerprints from data and cache
    let cacheFP = await cacheHandler.getFingerprint()
      let dataVersion = dataHandler.getVersion()
      let currentFP = await self.formatFingerprint(dataVersion: dataVersion)
      
      if dataVersion == nil || cacheFP != currentFP {
        if dataVersion == nil {
          print("++ data version is nil, updating cache")
        } else {
          print("++ fingerprint mismatch, updating cache")
        }
        
        let eveObjects = await EveObjectBuilder.run(dataHandler: dataHandler)
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
