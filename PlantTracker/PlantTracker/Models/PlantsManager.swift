//
//  File.swift
//  PlantTracker
//
//  Created by Joshua on 8/27/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os

class PlantsManager {
    
    var plants = [Plant]()
    
    init() {
        loadPlants()
    }
    
    func loadPlants() {
        let defaults = UserDefaults.standard
        if let savedPlants = defaults.object(forKey: "plants") as? Data{
            let jsonDecoder = JSONDecoder()
            do {
                plants = try jsonDecoder.decode([Plant].self, from: savedPlants)
                os_log("Loaded %d plants", log: Log.plantsManager, type: .info, plants.count)
            } catch {
                os_log("Failed to load Plants.", log: Log.plantsManager, type: .error)
            }
        }
    }
    
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
            os_log("Saved %d plants.", log: Log.plantsManager, type: .default, plants.count)
        } else {
            os_log("Failed to save plants.", log: Log.plantsManager, type: .error)
        }
    }
    
    
    func newPlant() {
        os_log("Making new Plant.", log: Log.plantsManager, type: .default)
        plants.append(Plant(scientificName: nil, commonName: nil))
        savePlants()
    }
    
}


// MARK: Testing
extension PlantsManager {
    func makeTestPlantsArray() {
        os_log("Loading test plants.", log: Log.plantLibraryTableVC, type: .info)
        plants = [
            Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
            Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
            Plant(scientificName: nil, commonName: "split rock"),
            Plant(scientificName: "Lithops julii", commonName: nil),
            Plant(scientificName: nil, commonName: nil),
        ]
    }
}
