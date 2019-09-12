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
            setupEditingCell()
            
            editingCell.segmentedControl.allowsMultipleSelection = plantLevel != .difficultyLevel
        }
    }
    
    var detailLabelOfCellBeingEdited: UILabel?
    
    var editingRowIndex: Int?
    
    unowned var editingCell: EditingTableViewCell
    
    var allItems: [String]?
    var allCases: [Any]?
    var plantItems: [String]?
    
    var parentTableViewDelegate: ParentTableViewDelegate?
    
    init(plant: Plant, plantLevel: PlantLevel, editingCell: EditingTableViewCell) {
        self.plant = plant
        self.editingCell = editingCell
        
        super.init()
        
        // call this after super init because it has a didSet property
        // that calls set-up methods
        self.plantLevel = plantLevel
        
        // make self delegate for editing cell multi-select segmented controller
        editingCell.segmentedControl.delegate = self
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
    
    private func setupEditingCell() {
        setUpEditingCellSegmentedControllerItems()
    }
    
    
    private func setUpEditingCellSegmentedControllerItems() {
        editingCell.segmentedControl.items = allItems ?? [Any]()
        editingCell.segmentedControl.selectedSegmentIndexes = indexesToSelect(forSegmentedController: editingCell.segmentedControl)
        editingCell.segmentedControl.reloadInputViews()
    }
    
    private func indexesToSelect(forSegmentedController segmentedController: MultiSelectSegmentedControl) -> IndexSet {
        os_log("Setting the correct tabs for selection in segmented controller.", log: Log.editPlantManager, type: .info)
        
        guard plantItems != nil else { return IndexSet() }
        
        var selectedIndexes = [Int]()
        if let segmentItems = segmentedController.items as? [String] {
            for (i, segmentItem) in segmentItems.enumerated() {
                for plantItem in plantItems! {
                    if plantItem == segmentItem { selectedIndexes.append(i) }
                }
            }
        }
        
        os_log("Number of levels to set for segmented controller of editing cell: %d.", log: Log.editPlantManager, type: .debug, selectedIndexes.count)
        
        return IndexSet(selectedIndexes)
    }
    
}


extension EditPlantLevelManager: MultiSelectSegmentedControlDelegate {

    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        os_log("User selected an item; total number of values selected %d.", log: Log.editPlantManager, type: .info, multiSelectSegmentedControl.selectedSegmentIndexes.count)
        
        var selectedCases = [Any]()
        if let allCases = allCases {
            for index in multiSelectSegmentedControl.selectedSegmentIndexes {
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
                if multiSelectSegmentedControl.selectedSegmentIndexes.count > 0 {
                    let startIndex = multiSelectSegmentedControl.selectedSegmentIndexes.startIndex
                    plant.difficulty = allCases?[multiSelectSegmentedControl.selectedSegmentIndexes[startIndex]] as? DifficultyLevel
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
