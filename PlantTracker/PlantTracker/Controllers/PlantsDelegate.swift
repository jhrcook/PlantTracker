//
//  PlantsSaveDelegate.swift
//  PlantTracker
//
//  Created by Joshua on 8/3/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import Foundation

protocol PlantsDelegate: class {
    func savePlants()
    func loadPlants()
    func newPlant()
}
