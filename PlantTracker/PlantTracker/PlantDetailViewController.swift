//
//  PlantDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {

    @IBOutlet var plantImage: UIImageView!
    @IBOutlet var scientificNameLabel: UILabel!
    @IBOutlet var commonNameLabel: UILabel!
    
    var plant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlantDetail))
        
        // load image
        if let imageName = plant?.image {
            plantImage.image = UIImage(named: imageName)
        } else {
            plantImage.image = UIImage(named: "cactus")
        }
        
        // scientific name
        if let scientificName = plant?.scientificName {
            scientificNameLabel.text = scientificName
        } else {
            scientificNameLabel.text = "untitled"
            scientificNameLabel.textColor = .gray
        }
        scientificNameLabel.font = UIFont.italicSystemFont(ofSize: 20.0)
        
        // common name
        commonNameLabel.text = plant?.commonName ?? "untitled"
    }
    
    // edit information on the plant
    @objc func editPlantDetail() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Edit information", style: .default, handler: editPlantInformation))
        alertController.addAction(UIAlertAction(title: "Add photograph", style: .default, handler: addPhotograph))
        alertController.addAction(UIAlertAction(title: "Delete plant", style: .destructive, handler: removePlant))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func editPlantInformation(_ alertAction: UIAlertAction) {
        
    }
    
    func addPhotograph(_ alertAction: UIAlertAction) {
        
    }
    
    func removePlant(_ alertAction: UIAlertAction) {
        
    }
}


