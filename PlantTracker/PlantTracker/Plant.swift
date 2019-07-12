//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

enum LightingLevel: String, Codable, CaseIterable {
    case direct = "☀️"
    case morning = "🌞"
    case indirect = "⛅️"
    case shade = "🌲"
    case low = "🌚"
    case indoors = "🏠"
}

enum WateringLevel: String, Codable, CaseIterable {
    case drought = "🐪"
    case dry = "🐘"
    case often = "🐢"
    case high = "🐠"
}

enum DifficultyLevel: Int, Codable, CaseIterable {
    case beginner = 1, intermediate, professional
}

enum Season: String, Codable, CaseIterable {
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
    var dormantSeason: Season?
    
    init(scientificName: String?, commonName: String) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
    
    func simpleDescription() {
        print("\(scientificName ?? "untitled") (\(commonName ?? "untitled"))")
    }
    
    func deleteImageFiles() {
        let fileManager = FileManager()
        for image in images {
            do {
                try fileManager.removeItem(atPath: image)
                print("Deleted file: \(image)")
            } catch {
                print("Failed to delete the file \(image).")
            }
        }
    }
}
