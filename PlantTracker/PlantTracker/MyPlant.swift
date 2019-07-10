//
//  MyPlant.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class MyPlant: Plant {
    // unique identifier for each plant instance
    let uuid = UUID()
    
    // purchase information
    var dateOfPurchase: Date?
    var purchasedFrom: SucculentSource?
    var purchasePrice: Float?
    
    // tracking information
    var lastWatered: Date?
    var isAlive = true
    
    var age: TimeInterval? {
        get {
            if let birth = dateOfPurchase {
                return birth.timeIntervalSinceNow
            } else {
                return nil
            }
        }
    }
}
