//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryViewController: UITableViewController {
    
    var plants = [Plant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add new plant
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
        
        // load library
        let defaults = UserDefaults.standard
        if let savedPlants = defaults.object(forKey: "plants") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                plants = try jsonDecoder.decode([Plant].self, from: savedPlants)
            } catch {
                print("Failed to load `plants`")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    // specify what each row should look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Plant", for: indexPath)
        let plant = plants[indexPath.row]
        cell.textLabel?.text = plant.commonName
        if plant.images.count > 0 {
            cell.imageView?.image = UIImage(named: plant.images[0])
        } else {
            cell.imageView?.image = UIImage(named: "cactus")
        }
        cell.detailTextLabel?.text = plant.scientificName
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PlantDetail") as? PlantDetailViewController {
            viewController.plant = plants[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func addNewPlant() {
        let alertController = UIAlertController(title: "New plant name", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Add name", style: .default) { [weak self, weak alertController] _ in
            guard let newPlantName = alertController?.textFields?[0].text else { return }
            let plant = Plant(scientificName: nil, commonName: newPlantName)
            self?.plants.append(plant)
            self?.tableView.reloadData()
            self?.saveLibrary()
        })
        present(alertController, animated: true)
    }
    
    func saveLibrary() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
        } else {
            print("Failed to save `plants`.")
        }
    }

}
