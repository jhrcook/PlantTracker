//
//  GeneralPlantInformationTableViewController.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os

class GeneralPlantInformationTableViewController: UITableViewController {

    var plant: Plant!
    var plantsManager: PlantsManager!
    
    var editManager: EditPlantLevelManager?
    var editingPlantLevelCell: EditingTableViewCell?
    
    func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        
        editingPlantLevelCell = EditingTableViewCell(style: .default, reuseIdentifier: nil, items: nil)
        
        editManager = EditPlantLevelManager(plant: plant, plantLevel: .difficultyLevel, editingCell: editingPlantLevelCell!)
        editManager?.plantsManager = self.plantsManager
        editManager?.parentTableViewDelegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editManager?.editingRowIndex == nil ? 7 : 8
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let editingIndex = editManager?.editingRowIndex {
            if indexPath.row < editingIndex {
                var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
                addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row)
                return cell
            } else if indexPath.row == editingIndex {
                return editingPlantLevelCell!
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
    
    
    func addGeneralInformation(toCell cell: inout UITableViewCell, forIndexPathRow row: Int) {
        var main: String?
        var detail: String?
        
        switch row {
        case 0:
            main = "Scientific name"
            detail = plant.scientificName
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: cell.detailTextLabel?.font.pointSize ?? UIFont.systemFontSize)
        case 1:
            main = "Common name"
            detail = plant.commonName
        case 2:
            main = "Growing season(s)"
            detail = plant.printableGrowingSeason()
        case 3:
            main = "Dormant season(s)"
            detail = plant.printableDormantSeason()
        case 4:
            main = "Difficulty"
            if let difficulty = plant.difficulty { detail = String(difficulty.rawValue) }
        case 5:
            main = "Watering level(s)"
            detail = plant.printableWatering()
        case 6:
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
        
        switch indexPath.row {
        case 0:
            getNewName(for: .scientificName)
            return
        case 1:
            getNewName(for: .commonName)
            return
        default:
            break
        }
        
        tableView.performBatchUpdates({
            if self.editManager?.editingRowIndex == nil {
                // add editing row
                editManager?.editingRowIndex = indexPath.row + 1
                editManager?.plantLevel = getPlantLevel(forRow: indexPath.row)
                editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: indexPath)?.detailTextLabel
                let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.insertRows(at: [newEditingIndexPath], with: .top)
            } else if editManager!.editingRowIndex! - 1 == indexPath.row {
                // remove editing row
                let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                editManager?.editingRowIndex = nil
                editManager?.detailLabelOfCellBeingEdited = nil
                tableView.deleteRows(at: [editingIndexPath], with: .top)
            } else {
                // move editing row
                let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.deleteRows(at: [editingIndexPath], with: .top)
                editManager!.editingRowIndex = editManager!.editingRowIndex! > indexPath.row ? indexPath.row + 1 : indexPath.row
                let originalIndex = editManager!.editingRowIndex! > indexPath.row ? indexPath.row : indexPath.row - 1
                editManager!.plantLevel = getPlantLevel(forRow: originalIndex)
                editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: IndexPath(item: originalIndex, section: 0))?.detailTextLabel
                let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
                tableView.insertRows(at: [newEditingIndexPath], with: .top)
            }
        }, completion: { _ in
            print("completed move")
            print("  selected index: \(indexPath.row)")
            if let row = self.editManager?.editingRowIndex {
                print("  new edting row: \(row)")
            } else {
                print("  editing row removed")
            }
            
        })
    }
    
    
    func getPlantLevel(forRow row: Int) -> EditPlantLevelManager.PlantLevel {
        switch row {
        case 2:
            return .growingSeason
        case 3:
            return .dormantSeason
        case 4:
            return .difficultyLevel
        case 5:
            return .wateringLevel
        case 6:
            return .lightingLevel
        default:
            fatalError("Unknown number of row.")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func reloadGeneralInfoTableViewAndSavePlants() {
        tableView.reloadData()
        plantsManager.savePlants()
    }

}


extension GeneralPlantInformationTableViewController {
    
    enum PlantName { case scientificName, commonName }
    
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
                    self?.tableView.reloadData()
                }
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}



extension GeneralPlantInformationTableViewController: ParentTableViewDelegate {
    func reloadParentTableViewData() {
//        tableView.reloadData()
    }
}
