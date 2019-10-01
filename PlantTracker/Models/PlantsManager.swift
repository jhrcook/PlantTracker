//
//  File.swift
//  PlantTracker
//
//  Created by Joshua on 8/27/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os

/**
 A manager of the fundamental plant objects for the app. It loads, saves, and adds  plants to the array `plants: [Plant]`.
 This manager should be created at start-up and passed to various view controllers.
 */
class PlantsManager {
    
    /// The central array that holds all of the `Plant` objects for the user.
    var plants = [Plant]()
    
    /// Loads the plants into `plants: [Plant]`
    init() {
        loadPlants()
    }
    
    /// Loads the plants from disk. It is already called during initialization.
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
    
    /// Save the plants to disk.
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
    
    /// Make a new plant with `nil` for scientific and common names and append to `plants: [Plant]`.
    func newPlant() {
        os_log("Making new Plant.", log: Log.plantsManager, type: .default)
        plants.append(Plant(scientificName: nil, commonName: nil))
        savePlants()
    }
    
}


// MARK: Testing

extension PlantsManager {
    
    /// Makes a test array of plants for use during development.
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
