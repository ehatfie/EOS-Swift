//
//  RestrictionService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/21/25.
//

class RestrictionService: MaybeFitHaving {
  weak var fit: Fit?
  
  let restrictions: [any BaseRestrictionProtocol]
  
  init(fit: Fit) {
    self.fit = fit
    
    self.restrictions = [
//      BoosterIndexRestrictionRegister(fit: fit),
//                  CalibrationRestriction(fit: fit),
//      CapitalItemRestrictionRegister(fit: fit),
      ChargeGroupRestrictionRegister(fit: fit),
      ChargeSizeRestrictionRegister(fit: fit),
      ChargeVolumeRestrictionRegister(fit: fit),
//                  CpuRestriction(fit: fit),
//                  DroneBandwidthRestriction(fit: fit),
//                  DroneBayVolumeRestriction(fit: fit),
//      DroneGroupRestrictionRegister(fit: fit),
//                  FighterSquadHeavyRestriction(fit: fit),
//                  FighterSquadLightRestriction(fit: fit),
//                  FighterSquadRestriction(fit: fit),
//                  FighterSquadSupportRestriction(fit: fit),
//                  HighSlotRestriction(fit: fit),
//                  ImplantIndexRestrictionRegister(fit: fit),
//      ItemClassRestriction(fit: fit),
//                  LaunchedDroneRestriction(fit: fit),
//                  LauncherSlotRestriction(fit: fit),
//                  LoadedItemRestriction(fit: fit),
//                  LowSlotRestriction(fit: fit),
//                  MaxGroupActiveRestrictionRegister(fit: fit),
//                  MaxGroupFittedRestrictionRegister(fit: fit),
//                  MaxGroupOnlineRestrictionRegister(fit: fit),
//                  MidSlotRestriction(fit: fit),
//                  PowergridRestriction(fit: fit),
//                  RigSizeRestrictionRegister(fit: fit),
//                  RigSlotRestriction(fit: fit),
//                  ShipTypeGroupRestrictionRegister(fit: fit),
//                  SkillRequirementRestrictionRegister(fit: fit),
//                  StateRestrictionRegister(fit: fit),
//                  SubsystemIndexRestrictionRegister(fit: fit),
//                  SubsystemSlotRestriction(fit: fit),
//                  TurretSlotRestriction(fit: fit)
    ]
  }
  
  func validate(skipChecks: [Any]) throws {
    /*
     """Validate fit.

     Args:
         skip_checks (optional): Iterable with restriction types validation
             should ignore. By default, nothing is ignored.

     Raises:
         ValidationError: If fit validation fails. Its single argument
             contains extensive data on reason of failure. Refer to
             restriction service docs for format of the data.
     """
     # Container for validation error data
     # Format: {item: {error type: error data}}
     invalid_items = {}
     # Go through all known registers
     for restriction in self.__restrictions:
         # Skip check if we're told to do so, based on restriction class
         # assigned to the register
         restriction_type = restriction.type
         if restriction_type in skip_checks:
             continue
         # Run validation for current register, if validation failure
         # exception is raised - add it to container
         try:
             restriction.validate()
         except RestrictionValidationError as e:
             # All erroneous items should be in 1st argument of raised
             # exception
             exception_data = e.args[0]
             for item in exception_data:
                 item_error = exception_data[item]
                 item_errors = invalid_items.setdefault(item, {})
                 item_errors[restriction_type] = item_error
     # Raise validation error only if we got any failures
     if invalid_items:
         raise ValidationError(invalid_items)
     */
  }
}
