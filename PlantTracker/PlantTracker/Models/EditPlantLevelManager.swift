//
//  EditPlantLevelManager.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class EditPlantLevelManager: NSObject {
    var plant: Plant
    
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case difficultyLevel = "Difficulty Level"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    var plantLevel: PlantLevel
    
    init(plant: Plant, plantLevel: PlantLevel) {
        self.plant = plant
        self.plantLevel = plantLevel
    }
}
