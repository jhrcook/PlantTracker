//
//  EditPlantLevelManager.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl


protocol ParentTableViewDelegate {
    func reloadParentTableViewData(forCellAtRow row: Int)
}


class EditPlantLevelManager: NSObject {
    var plant: Plant
    var plantsManager: PlantsManager?
    
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case difficultyLevel = "Difficulty Level"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    var plantLevel: PlantLevel {
        didSet {
            setAllItems()
            setPlantItems()
        }
    }
    
    var editingRowIndex: Int?
    
    var allItems: [String]?
    var allCases: [Any]?
    var plantItems: [String]?
    
    var parentTableViewDelegate: ParentTableViewDelegate?
    
    
    init(plant: Plant, plantLevel: PlantLevel) {
        self.plant = plant
        self.plantLevel = plantLevel
        
        super.init()
        
        setAllItems()
        setPlantItems()
    }
    
    
    private func setAllItems() {
        switch plantLevel {
        case .growingSeason, .dormantSeason:
            allItems = Season.allCases.map { $0.rawValue }
            allCases = Season.allCases
        case .difficultyLevel:
            allItems = DifficultyLevel.allCases.map { $0.rawValue }
            allCases = DifficultyLevel.allCases
        case .wateringLevel:
            allItems = WateringLevel.allCases.map { $0.rawValue }
            allCases = WateringLevel.allCases
        case .lightingLevel:
            allItems = LightLevel.allCases.map { $0.rawValue }
            allCases = LightLevel.allCases
        }
    }
    
    private func setPlantItems() {
        switch plantLevel {
        case .growingSeason:
            plantItems = plant.growingSeason.map { $0.rawValue }
        case .dormantSeason:
            plantItems = plant.dormantSeason.map { $0.rawValue }
        case .difficultyLevel:
            if let difficultyLevel = plant.difficulty?.rawValue {
                plantItems = [difficultyLevel]
            }
        case .wateringLevel:
            plantItems = plant.watering.map { $0.rawValue }
        case .lightingLevel:
            plantItems = plant.lighting.map { $0.rawValue }
        }
    }
    
}


extension EditPlantLevelManager: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        print("selected indices: \(multiSelectSegmentedControl.selectedSegmentIndexes)")
        
        let selectedIndexes: [Int] = multiSelectSegmentedControl.selectedSegmentIndexes.map { Int($0) }
        
        print(selectedIndexes)
        
        var selectedCases = [Any]()
        if let allCases = allCases {
            for index in selectedIndexes {
                selectedCases.append(allCases[index])
            }
        }
        
        print(selectedCases)
        
        switch plantLevel {
        case .growingSeason:
            plant.growingSeason = selectedCases as? [Season] ?? [Season]()
        case .dormantSeason:
            plant.dormantSeason = selectedCases as? [Season] ?? [Season]()
        case .difficultyLevel:
            plant.difficulty = allCases?[selectedIndexes[0]] as? DifficultyLevel
        case .wateringLevel:
            plant.watering = selectedCases as? [WateringLevel] ?? [WateringLevel]()
        case .lightingLevel:
            plant.lighting = selectedCases as? [LightLevel] ?? [LightLevel]()
        }
        
        if let delegate = plantsManager { delegate.savePlants() }
        if let delegate = parentTableViewDelegate { delegate.reloadParentTableViewData(forCellAtRow: editingRowIndex! - 1) }
    }
    
    
    func setUpSegmentedController(_ multiSelectSegmentedControl: MultiSelectSegmentedControl) {
        setSelectedSegments(multiSelectSegmentedControl)
        
        // difficulty level only allows for a single selection
        multiSelectSegmentedControl.allowsMultipleSelection = plantLevel != .difficultyLevel
    }
    
    
    func setSelectedSegments(_ multiSelectSegmentedControl: MultiSelectSegmentedControl) {
        guard plantItems != nil else { return }
        
        var selectedIndeces = [Int]()
        
        if let segmentItems = multiSelectSegmentedControl.items as? [String] {
            for (i, segmentItem) in segmentItems.enumerated() {
                for plantItem in plantItems! {
                    if plantItem == segmentItem { selectedIndeces.append(i) }
                }
            }
        }
        
        multiSelectSegmentedControl.selectedSegmentIndexes = IndexSet(selectedIndeces)
    }
    
}
