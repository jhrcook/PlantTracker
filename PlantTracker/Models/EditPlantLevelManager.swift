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
    func plantLevelDidChange()
}


class EditPlantLevelManager: NSObject {
    
    /// The plant object to be edited
    unowned var plant: Plant
    
    /// The plants manager to handle global operations on the plants
    /// such as writing changes to disk
    unowned var plantsManager: PlantsManager?
    
    /// A delegate to link the editing manager to the table view controller that
    /// owns it.
    var parentTableViewDelegate: ParentTableViewDelegate?
    
    /// The various levels of the plant that can be changed
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case difficultyLevel = "Difficulty Level"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    
    /**
     The plant level that is being operated on.
     
     When it is set, this causes a "reset" for the manager by having it set
     the `allItems` array, the `plantItems` array, and making a new editing
     cell.
     */
    var plantLevel: PlantLevel? {
        didSet {
            os_log("plant level of edit manager was set: %@", log: Log.editPlantManager, type: .info, plantLevel?.rawValue ?? "NIL")
            setAllItems()
            setPlantItems()
            setupEditingCell()
        }
    }
    
    /**
     All of the cases for the plant level being edited.
     
     For example, if `plantLevel` is `PlantLevel.dormantSeason`, then `allCases`
     holds all of the possible values in the `Season` enum.
     */
    var allCases: [Any]?
    
    /**
     All of the raw values (as `String`s) from the cases in `allCases`.
     
     For example, if `plantLevel` is `PlantLevel.dormantSeason`, then `allItems`
     holds all of the possible raw values in the `Season` enum.
     */
    var allItems: [String]?
    
    /**
     The values from `allItems` that are selected for the `plant` object.
     
     For example, if `plantLevel` is `PlantLevel.dormantSeason`, then
     `plantItems`holds the raw values of the cases of the `Season` enum for
     which the plant is dormant. The values will be already selected in the
     segmented controller.
     */
    var plantItems: [String]?
    
    /**
     The detail label of the cell with the plant's information that is being
     edited.
     
     By keeping it within this manager, it can be live-updated as a new value
     is selected in the editing row.
     */
    var detailLabelOfCellBeingEdited: UILabel?
    
    /// The index in the parent table view that is being edited.
    /// This is mainly used by the owner view controller for tracking the
    /// cell being edited.
    var editingRowIndex: Int?
    
    /// The actual cell that is presented to the user with the various options
    /// to select from the change the plant's information.
    var editingCell: EditingTableViewCell?
    
    
    init(plant: Plant, plantLevel: PlantLevel) {
        self.plant = plant
        
        super.init()
        
        // call this after super init because it has a didSet property
        // that calls set-up methods
        self.plantLevel = plantLevel
        
        // make self delegate for editing cell multi-select segmented controller
        editingCell?.segmentedControl.delegate = self
    }
    
    
    /// Set the `allItems` and `allCases` arrays depending on the `plantLevel`.
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
    
    
    /// Set the `plantItems` array depending on the `plantLevel` and current
    /// value(s) set for the plant.
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
    
    
    /// Prepare the cell to present to the user with a segmented controller
    /// containing the options to be selected.
    private func setupEditingCell() {
        editingCell = EditingTableViewCell(style: .default, reuseIdentifier: nil, items: allItems ?? [Any]())
        editingCell?.segmentedControl.delegate = self
        setUpEditingCellSegmentedControllerItems()
    }
    
    
    /// Prepare the segmented controller for the editing cell.
    private func setUpEditingCellSegmentedControllerItems() {
        guard let cell = editingCell else { return }
        cell.segmentedControl.allowsMultipleSelection = plantLevel != .difficultyLevel
        cell.segmentedControl.selectedSegmentIndexes = indexesToSelect(forSegmentedController: cell.segmentedControl)
        cell.segmentedControl.reloadInputViews()
    }
    
    
    
    /// Get the indeces to be set for the segmented controller in the editing cell
    ///
    /// - Parameter segmentedController: The segmented controller to be set (it is not actually mutated in this method).
    /// - Returns: The `IndexSet` to assign to the segmented controller.
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

    /// The method called when the segmented controller changes.
    ///
    /// The plant object is updated based on the selected cells in the segmented
    /// controller. Afterwards, the `plantsManager` is asked to save the plants
    /// and the parent table view controller is notified.
    ///
    /// - Parameters:
    ///   - multiSelectSegmentedControl: The segmented controller that has a change in value.
    ///   - value: A `Bool` for if the value did change.
    ///   - index: The index of the change.
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        os_log("User selected an item; total number of values selected %d.", log: Log.editPlantManager, type: .info, multiSelectSegmentedControl.selectedSegmentIndexes.count)
        
        // The cases of `allCases` that are selected in the segmented controller
        var selectedCases = [Any]()
        if let allCases = allCases {
            for index in multiSelectSegmentedControl.selectedSegmentIndexes {
                selectedCases.append(allCases[index])
            }
        }
        
        // Update the plant
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
        
        // use the `plantsManager` to save the changes to the plant
        if let delegate = plantsManager {
            os_log("Saving plants after changing levels.", log: Log.editPlantManager, type: .info)
            delegate.savePlants()
        }
        
        // Notify the parent view controller of the change
        if let delegate = parentTableViewDelegate {
            os_log("Notifying the parent view controller of the change in plant level.", log: Log.editPlantManager, type: .info)
            delegate.plantLevelDidChange()
        }
    }
    
}
