//
//  EditPlantLevelManager.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os
import MultiSelectSegmentedControl


protocol ParentTableViewDelegate {
    func reloadParentTableViewData()
}


class EditPlantLevelManager: NSObject {
    unowned var plant: Plant
    unowned var plantsManager: PlantsManager?
    
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case difficultyLevel = "Difficulty Level"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    var plantLevel: PlantLevel? {
        didSet {
            os_log("plant level of edit manager was set: %@", log: Log.editPlantManager, type: .info, plantLevel?.rawValue ?? "NIL")
            setAllItems()
            setPlantItems()
            setSegmentedControllerItems()
            if segmentedController != nil { setUpSegmentedController() }
        }
    }
    
    var detailLabelOfCellBeingEdited: UILabel?
    
    var editingRowIndex: Int?
    
    unowned var segmentedController: MultiSelectSegmentedControl?
    
    var allItems: [String]?
    var allCases: [Any]?
    var plantItems: [String]?
    
    var parentTableViewDelegate: ParentTableViewDelegate?
    
    init(plant: Plant) {
        self.plant = plant
        super.init()
    }
    
    init(plant: Plant, plantLevel: PlantLevel) {
        self.plant = plant
        self.plantLevel = plantLevel
        
        super.init()
        
        setAllItems()
        setPlantItems()
        setSegmentedControllerItems()
    }
    
    
    private func setAllItems() {
        guard let plantLevel = self.plantLevel else {
            os_log("Unable to set all items.", log: Log.editPlantManager, type: .info)
            return
        }
        
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
        
        os_log("Set all items (%d).", log: Log.editPlantManager, type: .info, allCases?.count ?? 0)
    }
    
    private func setPlantItems() {
        guard let plantLevel = self.plantLevel else {
            os_log("Unable to set plant items.", log: Log.editPlantManager, type: .info)
            return
        }
        
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
        
        os_log("Set plant items (%d).", log: Log.editPlantManager, type: .info, plantItems?.count ?? 0)
    }
    
    private func setSegmentedControllerItems() {
        guard
            let segmentedController = segmentedController,
            let allItems = allItems
        else {
            os_log("Unable to set segmented controller items.", log: Log.editPlantManager, type: .info)
            return
        }
        
        segmentedController.items = allItems
        
        os_log("Set segmented controller items.", log: Log.editPlantManager, type: .info, segmentedController.items.count)
    }
    
}


extension EditPlantLevelManager: MultiSelectSegmentedControlDelegate {
    
    func setUpSegmentedController() {
        os_log("Setting up segmented controller.", log: Log.editPlantManager, type: .info)
        
        setSelectedSegments()
        
        // difficulty level only allows for a single selection
        segmentedController?.allowsMultipleSelection = plantLevel != .difficultyLevel
    }
    
    
    fileprivate func setSelectedSegments() {
        os_log("Setting the correct tabs for selection in segmented controller.", log: Log.editPlantManager, type: .info)
        
        guard plantItems != nil else { return }
        
        var selectedIndeces = [Int]()
        
        if let segmentItems = segmentedController?.items as? [String] {
            for (i, segmentItem) in segmentItems.enumerated() {
                for plantItem in plantItems! {
                    if plantItem == segmentItem { selectedIndeces.append(i) }
                }
            }
        }
        
        os_log("Number of levels set: %d.", log: Log.editPlantManager, type: .debug, selectedIndeces.count)
        
        segmentedController?.selectedSegmentIndexes = IndexSet(selectedIndeces)
        segmentedController?.reloadInputViews()
    }
    
    
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        os_log("User selected an item; total number of values selected %d.", log: Log.editPlantManager, type: .info, multiSelectSegmentedControl.selectedSegmentIndexes.count)
        
        let selectedIndexes: [Int] = multiSelectSegmentedControl.selectedSegmentIndexes.map { Int($0) }
        
        var selectedCases = [Any]()
        if let allCases = allCases {
            for index in selectedIndexes {
                selectedCases.append(allCases[index])
            }
        }
        
        if let plantLevel = plantLevel {
            switch plantLevel {
            case .growingSeason:
                plant.growingSeason = selectedCases as? [Season] ?? [Season]()
                detailLabelOfCellBeingEdited?.text = plant.printableGrowingSeason()
            case .dormantSeason:
                plant.dormantSeason = selectedCases as? [Season] ?? [Season]()
                detailLabelOfCellBeingEdited?.text = plant.printableDormantSeason()
            case .difficultyLevel:
                if selectedIndexes.count > 0 {
                    plant.difficulty = allCases?[selectedIndexes[0]] as? DifficultyLevel
                } else {
                    plant.difficulty = nil
                }
                detailLabelOfCellBeingEdited?.text = plant.difficulty?.rawValue ?? ""
            case .wateringLevel:
                plant.watering = selectedCases as? [WateringLevel] ?? [WateringLevel]()
                detailLabelOfCellBeingEdited?.text = plant.printableWatering()
            case .lightingLevel:
                plant.lighting = selectedCases as? [LightLevel] ?? [LightLevel]()
                detailLabelOfCellBeingEdited?.text = plant.printableLighting()
            }
        }
        
        
        if let delegate = plantsManager {
            os_log("Saving plants after changing levels.", log: Log.editPlantManager, type: .info)
            delegate.savePlants()
        }
        
        if let delegate = parentTableViewDelegate {
            os_log("Requesting the reloading of parent table view.", log: Log.editPlantManager, type: .info)
            delegate.reloadParentTableViewData()
        }
    }
    
}
