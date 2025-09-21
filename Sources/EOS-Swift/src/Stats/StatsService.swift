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
  // var cpu: CpuRegister
  
  
  init(fit: Fit) {
    self.fit = fit
    
    self.ddRegister = DamageDealerRegister(fit: fit)
    self.armorRepRegister = ArmorRepairerRegister(fit: fit)
    self.shieldRepRegister = ShieldRepairerRegister(fit: fit)
  }
}
