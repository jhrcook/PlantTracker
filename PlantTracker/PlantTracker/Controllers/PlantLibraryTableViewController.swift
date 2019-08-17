//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os


class PlantLibraryTableViewController: UITableViewController {

    var plants = [Plant]()
    
    var iconImages = [Plant: UIImage]()
    var lastSelectedRow: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // remove the dark smudge behind the nav bar
        navigationController?.view.backgroundColor = .white  // do NOT delete //
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
        
        ///////////
        // TESTING
        if (false) {
            os_log("Loading test plants.", log: Log.plantLibraryTableVC, type: .info)
            plants = [
                Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
                Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
                Plant(scientificName: nil, commonName: "split rock"),
                Plant(scientificName: "Lithops julii", commonName: nil),
                Plant(scientificName: nil, commonName: nil),
            ]
            return()
        }
        ///////////
        
        loadPlants()
        getPlantIcons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savePlants()
        
        // so that image views are updated
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantLibraryTableViewCell
        
        // only update the cell if it has no `plant` or not the right one
        if cell.iconImageView == nil {
            // brand new cell
            cell.setupCell()
        }
        
        // add cell content
        let cellPlant = plants[indexPath.row]
        cell.scientificName = cellPlant.scientificName
        cell.commonName = cellPlant.commonName
        if let iconImage = iconImages[cellPlant] {
            cell.iconImageView.image = iconImage
        } else {
            let iconImage = resizeForIcon(image: UIImage(named: "cactusSmall")!)
            iconImages[cellPlant] = iconImage
            cell.iconImageView.image = iconImage
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func getPlantIcons() {
        os_log("Setting plant icons.", log: Log.plantLibraryTableVC, type: .info)
        for plant in plants {
            if let iconImageID = plant.smallRoundProfileImage {
                let iconImagePath = getFilePathWith(id: iconImageID)
                iconImages[plant] = UIImage(contentsOfFile: iconImagePath)!
            } else if let bestImageID = plant.bestSingleImage() {
                // make new icon image
                var image = UIImage(contentsOfFile: getFilePathWith(id: bestImageID))!
                image = makeNewIconFor(plant: plant, withImage: image)
                iconImages[plant] = image
            } else {
                iconImages[plant] = resizeForIcon(image: UIImage(named: "cactusSmall")!)
            }
        }
    }
    
    
    func resizeForIcon(image: UIImage) -> UIImage {
        var iconImage = crop(image: image, toWidth: 100, toHeight: 100)
        iconImage = resize(image: iconImage, targetSize: CGSize(width: 60, height: 60))
        return iconImage
    }
    
    
    func makeNewIconFor(plant: Plant, withImage image: UIImage) -> UIImage {
        os_log("creating icon for plant with UUID %@.", log: Log.plantLibraryTableVC, type: .info, plant.uuid)
        
        // make new icon image
        let iconImage = resizeForIcon(image: image)
        
        // save icon image for plant
        DispatchQueue.global(qos: .userInitiated).async { [weak plant] in
            // save image for future use
            let imageName = UUID().uuidString
            let imagePath = getFileURLWith(id: imageName)
            
            if let jpegData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try jpegData.write(to: imagePath)
                } catch {
                    os_log("Error when saving compressed icon. Error message: %@.", log: Log.plantLibraryTableVC, type: .error, error.localizedDescription)
                }
            } else {
                os_log("Unable to compress the icon image.", log: Log.detailLibraryVC, type: .error)
            }
            
            plant?.smallRoundProfileImage = imageName
        }
        
        return iconImage
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
                os_log("Loaded %d plants", log: Log.plantLibraryTableVC, type: .info, plants.count)
            } catch {
                os_log("Failed to load Plants.", log: Log.plantLibraryTableVC, type: .error)
            }
        }
    }
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
            os_log("Saved %d plants.", log: Log.plantLibraryTableVC, type: .default, plants.count)
        } else {
            os_log("Failed to save plants.", log: Log.plantLibraryTableVC, type: .error)
        }
    }
    
    
    func newPlant() {
        os_log("Making new Plant.", log: Log.plantLibraryTableVC, type: .default)
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
    
    
    func setIcon(for plant: Plant) {
        os_log("Setting icon for plant %@.", log: Log.plantLibraryTableVC, type: .info, plant.uuid)
        if let iconImageID = plant.smallRoundProfileImage {
            let iconImagePath = getFilePathWith(id: iconImageID)
            iconImages[plant] = UIImage(contentsOfFile: iconImagePath)!
        } else if let bestImageID = plant.bestSingleImage() {
            // make new icon image
            var image = UIImage(contentsOfFile: getFilePathWith(id: bestImageID))!
            image = makeNewIconFor(plant: plant, withImage: image)
            iconImages[plant] = image
        } else {
            iconImages[plant] = UIImage(named: "cactusSmall")!
        }
        
        tableView.reloadData()
    }
    
}



// MARK: editing style (swipe-to-edit)

extension PlantLibraryTableViewController {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = plants[indexPath.row]
            if UserDefaults.standard.bool(forKey: "in safe mode") {
                os_log("Double-checking with user to delete plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
                let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
                let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
                alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self, weak plant] _ in
                    os_log("Deleting plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
                    plant?.deleteAllImages()
                    self?.plants.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                })
                present(alertControler, animated: true)
            } else {
                os_log("Deleting plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
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
                lastSelectedRow = index
                os_log("Sending index %d to `LibraryDetailViewController`.", log: Log.plantLibraryTableVC, type: .info, index)
                vc.plant = plants[index]
                vc.plantsSaveDelegate = self
            }
        }
    }
    
    
    @IBAction func unwindToLibraryTableView(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? LibraryDetailViewController else { return }
        
        // Indicated that this plant should be removed in the detail view controller
        if sourceViewController.shouldDelete, let rowToDelete = lastSelectedRow {
            os_log("Recieving delete signaling from `LibraryDetailViewController`.", log: Log.plantLibraryTableVC, type: .default)
            let indexPath = IndexPath(row: rowToDelete, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, commit: .delete, forRowAt: indexPath)
        }
    }

}



