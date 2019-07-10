//
//  MyPlantsCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class MyPlantsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // make picker for library global
    var picker: UIPickerView!
    
    var myPlants = [MyPlant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlant))
        
        // load myPlants
        let defaults = UserDefaults.standard
        if let savedMyPlants = defaults.object(forKey: "myPlants") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                myPlants = try jsonDecoder.decode([MyPlant].self, from: savedMyPlants)
            } catch {
                print("Failed to load `myPlants`")
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPlants.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Plant", for: indexPath) as? MyPlantCollectionViewCell else {
            fatalError("unable to cast to `MyPlantCollectionViewCell`")
        }
        let plant = myPlants[indexPath.item]
        
        // cell label
        cell.name.text = plant.commonName ?? "untitled"
        cell.name.textAlignment = .center
        
        // cell image
        cell.imageView.image = UIImage(named: plant.images.count > 0 ? plant.images[0] : "cactus")
        cell.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        
        return cell
    }
    
    @objc func addPlant() {
        let alertController = UIAlertController(title: "Add Plant", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Add by new picture", style: .default, handler: addPlantByPhoto))
        alertController.addAction(UIAlertAction(title: "Add new plant from library", style: .default, handler: addPlantFromLibrary))
        alertController.addAction(UIAlertAction(title: "Add new species", style: .default, handler: newPlant))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func addPlantByPhoto(_ alertAction: UIAlertAction) {
        // get new image
        // use it to start a new instance of a MyPlant
    }
    
    func addPlantFromLibrary(_ alertAction: UIAlertAction) {
        // give list of plants in library to choose from
    }
    
    func newPlant(_ alertAction: UIAlertAction) {
        // make new MyPlant blank
    }
    
    
    // ---- put cells together with 3 per row ---- //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = yourWidth + 50
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // -------- //
    
    func saveMyPlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(myPlants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "myPlants")
        } else {
            print("Failed to save `myPlants`.")
        }
    }
}
