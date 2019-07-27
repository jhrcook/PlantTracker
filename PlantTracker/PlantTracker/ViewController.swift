//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewController: UITableViewController {

//    var plants = [Plant]()
    // Example `plants` data
    var plants = [
        Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
        Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
        Plant(scientificName: nil, commonName: "split rock"),
        Plant(scientificName: "Lithops julii", commonName: nil),
        Plant(scientificName: nil, commonName: nil),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlants()
        // Do any additional setup after loading the view.
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)
        let cellPlant = plants[indexPath.row]
        
        // main label
        if let scientificName = cellPlant.scientificName {
            cell.textLabel?.text = scientificName
        } else {
            cell.textLabel?.text = "Unnamed"
            cell.textLabel?.textColor = .gray
        }
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: cell.textLabel?.font.pointSize ?? UIFont.systemFontSize)
        
        // detail label
        cell.detailTextLabel?.text = cellPlant.commonName
        
        // cell image
        if let imageName = cellPlant.bestSingleImage() {
            cell.imageView?.image = UIImage(contentsOfFile: imageName)
        } else {
            cell.imageView?.image = UIImage(named: "cactus")
        }
        
        return cell
    }
    
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
        } else {
            print("Failed to save people.")
        }
    }
    
    
    func loadPlants() {
        let defaults = UserDefaults.standard
        if let savedPlants = defaults.object(forKey: "plants") as? Data{
            let jsonDecoder = JSONDecoder()
            do {
                plants = try jsonDecoder.decode([Plant].self, from: savedPlants)
            } catch {
                print("Failed to load `plants`")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LibraryDetailViewController {
            if plants.count > 0, let index = tableView.indexPathForSelectedRow?.row {
                print("sending index: \(index)")
                vc.plant = plants[index]
            }
        }
    }
    
}

