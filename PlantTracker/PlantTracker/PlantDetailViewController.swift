//
//  PlantDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {
    
    var plant: Plant!
    var plants = [Plant]()
    var plantIndex: Int? = nil

    var plantScrollView = UIScrollView()
    var scientificNameLabel = UILabel()
    var commonNameLabel = UILabel()
    let detailHeaderLabel = UILabel()
    let difficultyLabel = UILabel()
    let waterLabel = UILabel()
    let lightLabel = UILabel()
    let growingSeasonLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlantDetail))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        plants[plantIndex!] = plant
        savePlants()
        
        // ---- Layout ---- //
        let scrollViewHeight:CGFloat = 300.0
        let labelHeight:CGFloat = 24.0
        let standardSpacing:CGFloat = 8.0
        
        // plant scrolling images
        view.addSubview(plantScrollView)
        plantScrollView.backgroundColor = .lightGray
        plantScrollView.translatesAutoresizingMaskIntoConstraints = false
        plantScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        plantScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        plantScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        plantScrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight).isActive = true
        
        // scientific name
        view.addSubview(scientificNameLabel)
        if let scientificName = plant.scientificName {
            scientificNameLabel.text = scientificName
            scientificNameLabel.textColor = .black
        } else {
            scientificNameLabel.text = "untitled"
            scientificNameLabel.textColor = .gray
        }
        scientificNameLabel.font = UIFont.italicSystemFont(ofSize: 20.0)
        scientificNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scientificNameLabel.topAnchor.constraint(equalTo: plantScrollView.bottomAnchor, constant: 8.0).isActive = true
        scientificNameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        scientificNameLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        scientificNameLabel.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        
        // scientific name
        view.addSubview(commonNameLabel)
        commonNameLabel.text = plant.commonName ?? "untitled"
        commonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        commonNameLabel.topAnchor.constraint(equalTo: scientificNameLabel.bottomAnchor, constant: 8.0).isActive = true
        commonNameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        commonNameLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        commonNameLabel.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        
        // "Details" section label
        detailHeaderLabel.text = " Details"
        detailHeaderLabel.numberOfLines = 1
        detailHeaderLabel.backgroundColor = UIColor(white: 0, alpha: 0.1)
        view.addSubview(detailHeaderLabel)
        detailHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        detailHeaderLabel.topAnchor.constraint(equalTo: commonNameLabel.bottomAnchor, constant: 8.0).isActive = true
        detailHeaderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        detailHeaderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        detailHeaderLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        
        var previousLabel = detailHeaderLabel
        if let difficultyLevel = plant.difficultyLevel {
            view.addSubview(difficultyLabel)
            difficultyLabel.text = "Difficulty: \(difficultyLevel)"
            difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
            difficultyLabel.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: standardSpacing).isActive = true
            difficultyLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            difficultyLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            previousLabel = difficultyLabel
        }
        
        if let wateringRequirements = plant.wateringRequirements {
            view.addSubview(waterLabel)
            waterLabel.text = "Water requirements: \(wateringRequirements)"
            waterLabel.translatesAutoresizingMaskIntoConstraints = false
            waterLabel.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: standardSpacing).isActive = true
            waterLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            waterLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            previousLabel = waterLabel
        }
        
        if let lightRequirements = plant.lightRequirements {
            view.addSubview(lightLabel)
            lightLabel.text = "Light requirements: \(lightRequirements)"
            lightLabel.translatesAutoresizingMaskIntoConstraints = false
            lightLabel.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: standardSpacing).isActive = true
            lightLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            lightLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            previousLabel = lightLabel
        }
        
        if let growingSeason = plant.growingSeason {
            view.addSubview(growingSeasonLabel)
            growingSeasonLabel.text = "Growing season: \(growingSeason)"
            growingSeasonLabel.translatesAutoresizingMaskIntoConstraints = false
            growingSeasonLabel.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: standardSpacing).isActive = true
            growingSeasonLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            growingSeasonLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            previousLabel = growingSeasonLabel
        }
        // -------- //
        
        // ---- Fill in scrolling images ---- //
        if plant.images.count > 0 {
            for i in 1..<plant.images.count {
                let imageView = UIImageView(image: UIImage(named: plant.images[i]))
                let x = view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: x, y: 0, width: view.frame.width, height: scrollViewHeight)
                imageView.contentMode = .scaleAspectFit
                plantScrollView.addSubview(imageView)
            }
        } else {
            let imageView = UIImageView(image: UIImage(named: "cactus"))
            imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollViewHeight)
            imageView.contentMode = .scaleAspectFit
            plantScrollView.addSubview(imageView)
        }
        plantScrollView.contentSize.width = CGFloat(plantScrollView.subviews.count) * view.frame.width
        // -------- //
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
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PlantEditor") as? PlantEditorViewController {
            viewController.plant = plant
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func addPhotograph(_ alertAction: UIAlertAction) {
        // get photo from library or camera
        
        // save plant
        // reload view
    }
    
    func removePlant(_ alertAction: UIAlertAction) {
        let alertController = UIAlertController(title: "Delete plant?", message: "Are you certain you want to delete \(plant.scientificName ?? "this plant")?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.removePlantFromPlants()
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alertController, animated: true)
    }
    
    func removePlantFromPlants() {
        plants.remove(at: plantIndex!)
        savePlants()
    }
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
        } else {
            print("Failed to save `plants`.")
        }
    }
}


