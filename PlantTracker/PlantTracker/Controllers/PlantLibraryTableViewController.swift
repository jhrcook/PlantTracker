//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewController: UITableViewController {

    var plants = [Plant]()
    
    var lastSelectedRow: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove the dark smudge behind the nav bar
        navigationController?.view.backgroundColor = .white  // do NOT delete //
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
        
        loadPlants()
        // Do any additional setup after loading the view.
        
        ///////////
        // TESTING
        if (plants.count == 0 || false) {
            print("loading test plants")
            plants = [
                Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
                Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
                Plant(scientificName: nil, commonName: "split rock"),
                Plant(scientificName: "Lithops julii", commonName: nil),
                Plant(scientificName: nil, commonName: nil),
            ]
        }
        ///////////
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savePlants()
        
        // so that image views are updated
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        savePlants()
        print("view will disappear")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantLibraryTableViewCell
        cell.plant = plants[indexPath.row]
        cell.setupCell()
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



// MARK: PlantsSaveDelegate
extension PlantLibraryTableViewController: PlantsDelegate {
    
    func loadPlants() {
        let defaults = UserDefaults.standard
        if let savedPlants = defaults.object(forKey: "plants") as? Data{
            let jsonDecoder = JSONDecoder()
            do {
                plants = try jsonDecoder.decode([Plant].self, from: savedPlants)
                print("Loaded \(plants.count) plants.")
            } catch {
                print("Failed to load `plants`")
            }
        }
    }
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
            print("Saved plants.")
        } else {
            print("Failed to save plants.")
        }
    }
    
    func newPlant() {
        plants.append(Plant(scientificName: nil, commonName: nil))
        savePlants()
        tableView.reloadData()
    }

    @objc func addNewPlant() {
        newPlant()
        
        // "select" the new row in the table view
        let indexPath = IndexPath(row: plants.count-1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



// MARK: editing style (swipe-to-edit)

extension PlantLibraryTableViewController {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = plants[indexPath.row]
            if UserDefaults.standard.bool(forKey: "in safe mode") {
                let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
                let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
                alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self, weak plant] _ in
                    plant?.deleteAllImages()
                    self?.plants.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                })
                present(alertControler, animated: true)
            } else {
                plant.deleteAllImages()
                plants.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
        savePlants()
    }
}



// MARK: segues

extension PlantLibraryTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LibraryDetailViewController {
            if plants.count > 0, let index = tableView.indexPathForSelectedRow?.row {
                print("sending index: \(index)")
                vc.plant = plants[index]
                vc.plantsSaveDelegate = self
            }
        }
    }
    
    
    @IBAction func unwindToLibraryTableView(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? LibraryDetailViewController else { return }
        
        // Indicated that this plant should be removed in the detail view controller
        if sourceViewController.shouldDelete, let rowToDelete = lastSelectedRow {
            let indexPath = IndexPath(row: rowToDelete, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, commit: .delete, forRowAt: indexPath)
        }
    }

}
