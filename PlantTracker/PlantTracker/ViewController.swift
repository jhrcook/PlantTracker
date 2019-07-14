//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewController: UITableViewController {

    var plants = [
        Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
        Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
        Plant(scientificName: nil, commonName: "split rock"),
        Plant(scientificName: "Lithops julii", commonName: nil),
        Plant(scientificName: nil, commonName: nil),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // get highest
        if let imageName = cellPlant.bestSingleImage() {
            cell.imageView?.image = UIImage(contentsOfFile: imageName)
        } else {
            cell.imageView?.image = UIImage(named: "cactus")
        }
        
        return cell
    }
    
}

