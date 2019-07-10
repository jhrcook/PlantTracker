//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

enum LightingLevel: Int, Codable {
    case direct = 1, morning, indirect, shade, low, indoors
}

enum WateringLevel: Int, Codable {
    case drought = 1, dry, often, high
}

enum DifficultyLevel: Int, Codable {
    case beginner = 1, intermediate, professional
}

enum Season: Int, Codable {
    case summer, fall, winter, spring
}

class Plant: NSObject, Codable {
    
    // naming
    var scientificName: String?
    var commonName: String?
    
    // pictures
    var images = [String]()

    // detailed information
    var originLocation: String?
    var lightRequirements: LightingLevel?
    var wateringRequirements: WateringLevel?
    var difficultyLevel: DifficultyLevel?
    var growingSeason: Season?
    
    init(scientificName: String?, commonName: String) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
    
    func simpleDescription() {
        print("\(scientificName ?? "untitled") (\(commonName ?? "untitled"))")
    }
}
