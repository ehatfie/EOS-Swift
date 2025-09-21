//
//  StatsService.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/7/25.
//

class StatService {
  var fit: Fit? = nil
  
  var ddRegister: DamageDealerRegister
  var armorRepRegister: ArmorRepairerRegister
  var shieldRepRegister: ShieldRepairerRegister
  var cpu: CPURegister
  var powerGrid: PowergridRegister
  var calibration: CalibrationRegister
  // var dronebay: DronebayVolumeRegister
  // var droneBandwidth: DoneBandwidthRegister
  
  init(fit: Fit) {
    self.fit = fit
    
    self.ddRegister = DamageDealerRegister(fit: fit)
    self.armorRepRegister = ArmorRepairerRegister(fit: fit)
    self.shieldRepRegister = ShieldRepairerRegister(fit: fit)
    self.cpu = CPURegister(fit: fit)
    self.powerGrid = PowergridRegister(fit: fit)
    self.calibration = CalibrationRegister(fit: fit)
    
    
  }
}
