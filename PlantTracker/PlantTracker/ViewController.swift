//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var plants = [
        Plant(scientificName: "Planticus oneii", commonName: "Plant One"),
        Plant(scientificName: nil, commonName: "Plant Two"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add new plant
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    // specify what each row should look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Plant", for: indexPath)
        cell.textLabel?.text = plants[indexPath.row].commonName
        if let imageName = plants[indexPath.row].image {
            cell.imageView?.image = UIImage(named: imageName)
        } else {
            cell.imageView?.image = UIImage(named: "cactus")
        }
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
        })
        present(alertController, animated: true)
    }

}

