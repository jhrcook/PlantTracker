//
//  EditPlantLevelManager.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class EditPlantLevelManager: NSObject {
    var plant: Plant
    
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case difficultyLevel = "Difficulty Level"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    var plantLevel: PlantLevel {
        didSet {
            setItems()
        }
    }
    
    var editingRowIndex: Int?
    
    var items: [Any]?
    
    init(plant: Plant, plantLevel: PlantLevel) {
        self.plant = plant
        self.plantLevel = plantLevel
        
        super.init()
        
        setItems()
    }
    
    
    private func setItems() {
        switch plantLevel {
        case .growingSeason, .dormantSeason:
            items = Season.allCases
        case .difficultyLevel:
            items = DifficultyLevel.allCases
        case .wateringLevel:
            items = WateringLevel.allCases
        case .lightingLevel:
            items = LightLevel.allCases
        }
    }
}


extension EditPlantLevelManager: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        print("selected indices: \(multiSelectSegmentedControl.selectedSegmentIndexes)")
    }
}
