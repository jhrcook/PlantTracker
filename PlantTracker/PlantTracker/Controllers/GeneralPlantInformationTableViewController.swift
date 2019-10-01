//
//  GeneralPlantInformationTableViewController.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os


/// The order of the plants used for the index of the plant information in the table view.
enum PlantInformationIndex: Int, Equatable {
    case scientificName = 0, commonName, growingSeason, dormantSeason, difficultyLevel, wateringLevel, lightingLevel
    
    /// Get the number of cases.
    static let count: Int = {
        var max: Int = 0
        while let _ = PlantInformationIndex(rawValue: max) { max += 1 }
        return max
    }()
}

/**
 Table view controller within the `LibraryDetailViewController` that presents the general information of a plant.
 The complexity of this view controller is mainly due to the system for editing the plant's atteributes.
 */
class GeneralPlantInformationTableViewController: UITableViewController {

    
    /// The plant object for the general information table view
    var plant: Plant!
    
    /// The `PlantsManager` delegate that handles tasks such as saving the plants
    /// if any information is edited
    var plantsManager: PlantsManager!
    
    /// Delegate to handle the editing row for collection type information
    /// - TODO: make private
    var editManager: EditPlantLevelManager?
    
    /// Prepares the view controller by setting it as the delegate for the table view
    /// and organizing the row editing manager and cell
    func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        
        editManager = EditPlantLevelManager(plant: plant, plantLevel: .difficultyLevel)
        editManager?.plantsManager = self.plantsManager
        editManager?.parentTableViewDelegate = self
    }

    // MARK: - Table view data source

    /// Number of sections in the general plant into table view.
    ///
    /// - Parameter tableView: standard iOS table view
    /// - Returns: the number of sections (1)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// How many rows for the general plant info table view.
    ///
    /// - Parameters:
    ///   - tableView: standard iOS table view
    ///   - section: which section of the table view (not used)
    /// - Returns: the number of rows that will be in the table; this value adjusts
    ///     depending on whether the edit row is available or not
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = PlantInformationIndex.count
        return editManager?.editingRowIndex == nil ? count : count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let editingIndex = editManager?.editingRowIndex {
            if indexPath.row < editingIndex {
                var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
                addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row)
                return cell
            } else if indexPath.row == editingIndex {
                return editManager!.editingCell!
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
                addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row - 1)
                return cell
            }
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
            addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row)
            return cell
        }
    }
    
    
    /// Adds the appropriate information to a cell of the general table view
    /// depending on the index.
    ///
    /// - Parameters:
    ///   - cell: the cell to add information to
    ///   - row: row number of the cell
    func addGeneralInformation(toCell cell: inout UITableViewCell, forIndexPathRow row: Int) {
        var main: String?
        var detail: String?
        
        switch row {
        case PlantInformationIndex.scientificName.rawValue:
            main = "Scientific name"
            detail = plant.scientificName
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: cell.detailTextLabel?.font.pointSize ?? UIFont.systemFontSize)
        case PlantInformationIndex.commonName.rawValue:
            main = "Common name"
            detail = plant.commonName
        case PlantInformationIndex.growingSeason.rawValue:
            main = "Growing season(s)"
            detail = plant.printableGrowingSeason()
        case PlantInformationIndex.dormantSeason.rawValue:
            main = "Dormant season(s)"
            detail = plant.printableDormantSeason()
        case PlantInformationIndex.difficultyLevel.rawValue:
            main = "Difficulty"
            if let difficulty = plant.difficulty { detail = String(difficulty.rawValue) }
        case PlantInformationIndex.wateringLevel.rawValue:
            main = "Watering level(s)"
            detail = plant.printableWatering()
        case PlantInformationIndex.lightingLevel.rawValue:
            main = "Lighting level(s)"
            detail = plant.printableLighting()
        default:
            main = nil
            detail = nil
        }
        
        cell.textLabel?.text = main
        cell.detailTextLabel?.text = detail
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        os_log("selected row %d", log: Log.detailLibraryGeneralInfoVC, type: .info, indexPath.row)
        
        // if the rows for plant names are selected, a alert controller with
        // a text field is used to get the text input
        switch indexPath.row {
        case PlantInformationIndex.scientificName.rawValue:
            getNewName(for: .scientificName)
            return
        case PlantInformationIndex.commonName.rawValue:
            getNewName(for: .commonName)
            return
        default:
            // a row with a name value was not selected --> continue with the rest of the method
            break
        }
        
        // update the table view for selection of a row with a plant level
        // defined by a collection of pre-determined values (eg. a season of
        // the year)
        tableView.performBatchUpdates({
            if self.editManager?.editingRowIndex == nil {   // ADD editing row
                // update edit manager
                editManager?.editingRowIndex = indexPath.row + 1
                editManager?.plantLevel = getPlantLevel(forRow: indexPath.row)
                editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: indexPath)?.detailTextLabel
                // insert the new row
                let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.insertRows(at: [newEditingIndexPath], with: .top)
                
            } else if editManager!.editingRowIndex! - 1 == indexPath.row {   // REMOVE editing row
                // update edit manager
                let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                editManager?.editingRowIndex = nil
                editManager?.detailLabelOfCellBeingEdited = nil
                // remove the cell from the table view
                tableView.deleteRows(at: [editingIndexPath], with: .top)
                
            } else {   // "MOVE" (delete and re-insert) editing row
                // delete the current editing cell
                let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.deleteRows(at: [editingIndexPath], with: .top)
                
                // figure out the index path indeces after removing the editing row
                let originalIndexOfSelectedRow = editManager!.editingRowIndex! < indexPath.row ? indexPath.row - 1 : indexPath.row
                editManager?.editingRowIndex = originalIndexOfSelectedRow + 1
                
                // configure editing manager for new plant level
                editManager!.plantLevel = getPlantLevel(forRow: originalIndexOfSelectedRow)
                editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: IndexPath(item: indexPath.row, section: 0))?.detailTextLabel
                let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.insertRows(at: [newEditingIndexPath], with: .top)
                
            }
        }, completion: { [weak self] _ in
            os_log("Completed update of table view for the selection plant level to edit.\n\tselected index: %d\n\tediting index: %d",
                   log: Log.detailLibraryGeneralInfoVC, type: .info,
                   indexPath.row, self?.editManager?.editingRowIndex ?? -1)
        })
    }
    
    
    /// Get the plent level selected for the editing manager
    ///
    /// - Parameter row: which row was tapped to edit
    /// - Returns: the plant level to be edited
    ///
    /// This is only applicable for cells that need to be edited by the edit
    /// manager, ie. not the scientific name nor the common name.
    func getPlantLevel(forRow row: Int) -> EditPlantLevelManager.PlantLevel? {
        switch row {
        case PlantInformationIndex.growingSeason.rawValue:
            return .growingSeason
        case PlantInformationIndex.dormantSeason.rawValue:
            return .dormantSeason
        case PlantInformationIndex.difficultyLevel.rawValue:
            return .difficultyLevel
        case PlantInformationIndex.wateringLevel.rawValue:
            return .wateringLevel
        case PlantInformationIndex.lightingLevel.rawValue:
            return .lightingLevel
        default:
            return nil
        }
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let index = editManager?.editingRowIndex, indexPath.row == index {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let normalCellHeight: CGFloat = 50
        let editingCellHeight: CGFloat = 40
        
        if let editingRowIndex = editManager?.editingRowIndex, editingRowIndex == indexPath.row {
            return editingCellHeight
        }
        return normalCellHeight
    }
    
    
    /// Reload the table view and save the plants data
    private func reloadGeneralInfoTableViewAndSavePlants() {
        tableView.reloadData()
        plantsManager.savePlants()
    }

}


extension GeneralPlantInformationTableViewController {
    
    enum PlantName { case scientificName, commonName }
    
    /// Change the plant's names using a Alert with a text field
    ///
    /// - Parameter plantName: which plant name to edit
    ///
    /// On completion, the table's data is reloaded and saved by calling
    /// `reloadGeneralInfoTableViewAndSavePlants`
    func getNewName(for plantName: PlantName) {
        let alertTitle = "Change the plant's \(plantName == .commonName ? "common name" : "scientific name")"
        let ac = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        ac.addTextField()
        switch plantName {
        case .scientificName:
            ac.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
                if let newName = ac.textFields?[0].text {
                    self?.plant.scientificName = newName
                    self?.title = newName
                    self?.reloadGeneralInfoTableViewAndSavePlants()
                }
            })
        case .commonName:
            ac.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
                if let newName = ac.textFields?[0].text {
                    self?.plant.commonName = newName
                    self?.reloadGeneralInfoTableViewAndSavePlants()
                    // self?.tableView.reloadData()
                }
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}



extension GeneralPlantInformationTableViewController: ParentTableViewDelegate {
    /// Called when a value is changed in the segmented controller of the
    /// editing cell. It currently does nothing.
    func plantLevelDidChange() {
        // Nothing to be done
    }
}
