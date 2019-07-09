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
    
    convenience init(scientificName: String?, commonName: String, dateOfPurchase: Date?, purchasedFrom: SucculentSource?, purchasePrice: Float?) {
        self.init(scientificName: scientificName, commonName: commonName)
        self.dateOfPurchase = dateOfPurchase
        self.purchasedFrom = purchasedFrom
        self.purchasePrice = purchasePrice
    }
}
