//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os

/**
 The view controller for the main table view of the Library collection. Each row is a different plant that can
 be selected to see detailed information. Swiping to delete is enabled. A new plant can be added through
 a navigation bar button ("+").
*/
class PlantLibraryTableViewController: UITableViewController {

    var plantsManager = PlantsManager()
    
    var iconImages = [Plant: UIImage]()
    var lastSelectedRow: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // remove the dark smudge behind the nav bar
        navigationController?.view.backgroundColor = .white  // do NOT delete //
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
        
        
        // TESTING //
//        plantsManager.makeTestPlantsArray()
        /////////////
        
        
        plantsManager.loadPlants()
        getPlantIcons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        plantsManager.savePlants()
        
        // so that image views are updated
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantsManager.plants.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantLibraryTableViewCell
        
        // only update the cell if it has no `plant` or not the right one
        if cell.iconImageView == nil {
            // brand new cell
            cell.setupCell()
        }
        
        // add cell content
        let cellPlant = plantsManager.plants[indexPath.row]
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
    
    /// If the plant has an icon stored, use that. Otherwise a new one if made (and saved) from the header
    /// image. If there are no images for the plant, the default image is used.
    func getPlantIcons() {
        os_log("Setting plant icons.", log: Log.plantLibraryTableVC, type: .info)
        for plant in plantsManager.plants {
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
    
    /// Insert a new plant.
    ///
    /// It begins with no name or data and the detail view is automatically pushed.
    @objc func addNewPlant() {
        plantsManager.newPlant()
        
        // "select" the new row in the table view
        let indexPath = IndexPath(row: plantsManager.plants.count-1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



// MARK: LibraryDetailContainerDelegate

extension PlantLibraryTableViewController: LibraryDetailContainerDelegate {
    
    /// If the plant has an icon stored, use that. Otherwise a new one if made (and saved) from the header
    /// image. If there are no images for the plant, the default image is used.
    ///
    /// - parameter plant: Plant object to set an icon for.
    ///
    /// - TODO:
    /// This looks very simillar to `getPlantIcons()` - they can likely be combined.
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
    
    /// The function for creating an icon.
    ///
    /// The final size is 60 x 60 pixels. `resizeForIcon(image:) -> UIImage` is used for the copping
    /// and resizing.
    ///
    /// - parameters:
    ///   - plant: Plant object to set an icon for.
    ///   - image: The image to use for the icon.
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
    
    /// Make an image the correct size for an icon.
    ///
    /// - parameter image: Image to resize.
    func resizeForIcon(image: UIImage) -> UIImage {
        var iconImage = crop(image: image, toWidth: 150, toHeight: 150)
        iconImage = resize(image: iconImage, targetSize: CGSize(width: 60, height: 60))
        return iconImage
    }

    
}



// MARK: editing style (swipe-to-edit)

extension PlantLibraryTableViewController {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = plantsManager.plants[indexPath.row]
            if UserDefaults.standard.bool(forKey: "in safe mode") {
                os_log("Double-checking with user to delete plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
                let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
                let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
                alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self, weak plant] _ in
                    os_log("Deleting plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
                    plant?.deleteAllImages()
                    self?.plantsManager.plants.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                })
                present(alertControler, animated: true)
            } else {
                os_log("Deleting plant at index %d.", log: Log.plantLibraryTableVC, type: .default, indexPath.row)
                plant.deleteAllImages()
                plantsManager.plants.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
        plantsManager.savePlants()
    }
}



// MARK: segues

extension PlantLibraryTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LibraryDetailViewController {
            if plantsManager.plants.count > 0, let index = tableView.indexPathForSelectedRow?.row {
                lastSelectedRow = index
                os_log("Sending index %d to `LibraryDetailViewController`.", log: Log.plantLibraryTableVC, type: .info, index)
                vc.plant = plantsManager.plants[index]
                vc.plantsManager = self.plantsManager
                vc.containerDelegate = self
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
