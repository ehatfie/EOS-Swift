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

class SolarSystem: MaybeFitHaving {
  var source: Source?
  weak var fit: Fit?
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


class SourceManager {
  nonisolated(unsafe) static let defaultValue: Source? = nil
  var sources: [String: Source] = [:]
  
  /// Add source to source manager
  /// Adding includes initializing all facilities hidden behind name 'source'.
  /// After source has been added, it is accessible with alias.
  func add(
    alias: String,
    dataHandler: Any?,
    cacheHandler: any BaseCacheHandlerProtocol,
    makeDefault: Bool = false
  ) {
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
    
    if self.sources.contains(where: { $0.key == alias }) {
      // raise ExistingSourceError(alias)
    }
    
    //Compare fingerprints from data and cache
    let cacheFP = cacheHandler.getFingerprint()
    
  }
}

struct Source {
  let alias: String
  let cacheHandler: any BaseCacheHandlerProtocol
}
