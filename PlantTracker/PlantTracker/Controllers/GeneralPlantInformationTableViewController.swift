//
//  GeneralPlantInformationTableViewController.swift
//  PlantTracker
//
//  Created by Joshua on 9/7/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class GeneralPlantInformationTableViewController: UITableViewController {

    var plant: Plant!
    var plantsManager: PlantsManager!
    
    var editingRowIndex: Int?
    var editManager: EditPlantLevelManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.delegate = self
        tableView.dataSource  = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editingRowIndex == nil ? 7 : 8
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
        
        var main: String?
        var detail: String?
        
        switch indexPath.row {
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
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! GeneralInformtationTableViewCell
        switch cell.textLabel?.text {
        case "Scientific name":
            getNewName(for: .scientificName)
        case "Common name":
            getNewName(for: .commonName)
        case "Growing season(s)":
//            editingRowIndex = indexPath.row + 1
            editManager = EditPlantLevelManager(plant: plant, plantLevel: .growingSeason)
        case "Dormant season(s)":
//            editingRowIndex = indexPath.row + 1
            editManager = EditPlantLevelManager(plant: plant, plantLevel: .dormantSeason)
        case "Difficulty":
//            editingRowIndex = indexPath.row + 1
            editManager = EditPlantLevelManager(plant: plant, plantLevel: .difficultyLevel)
        case "Watering level(s)":
//            editingRowIndex = indexPath.row + 1
            editManager = EditPlantLevelManager(plant: plant, plantLevel: .wateringLevel)
        case "Lighting level(s)":
//            editingRowIndex = indexPath.row + 1
            editManager = EditPlantLevelManager(plant: plant, plantLevel: .lightingLevel)
        default:
            break
        }
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let index = editingRowIndex, indexPath.row == index {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
