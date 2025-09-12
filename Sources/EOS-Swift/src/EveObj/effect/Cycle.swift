//
//  Cycle.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/10/25.
//

/*
 Holds information about cycle sequence.

 This class is used only when all cycles in sequence have the same
 parameters.

 Attributes:
     active_time: How long this effect is active.
     inactive_time: How long this effect is inactive after its activity.
     quantity: Defines how many times cycle should be repeated.
 */
class CycleInfo {
  let activeTime: Double
  let inactiveTime: Double
  let quantity: Double
  
  init(activeTime: Double, inactiveTime: Double, quantity: Double) {
    self.activeTime = activeTime
    self.inactiveTime = inactiveTime
    self.quantity = quantity
  }
  
  func getCycleQuantity() -> Double {
    return quantity
  }
  
  func getTime() -> Double {
    return (activeTime + inactiveTime) * quantity
  }
}

/*
 Holds information about cycle sequence.

 This class can be used when cycles it describes have different parameters.

 Attributes:
     sequence: Container-sequence, which holds cycle sequence definition in
         the form of CycleSequence of CycleInfo instances.
     quantity: Defines how many times the sequence should be repeated.
 */
/// Holds information about cycle sequence.
/// This class can be used when cycles it describes have different parameters.
class CycleSequence {
  var sequence: [CycleInfo] = []
  
  let quantity: Double
  
  init(sequence: [CycleInfo], quantity: Double) {
    self.sequence = sequence
    self.quantity = quantity
  }
  
  var averageTime: Double {
    return self.getTime() / self.getCycleQuantity()
  }
  
  func getCycleQuantity() -> Double {
    var quantity: Double = 0
    for item in self.sequence {
      quantity += item.getCycleQuantity()
    }
    return quantity
  }
  
  func getTime() -> Double {
    var time: Double = 0
    for item in self.sequence {
      time += item.getTime()
    }
    return time
  }
}
