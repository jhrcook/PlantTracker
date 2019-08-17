//
//  PlantDelegate.swift
//  PlantTracker
//
//  Created by Joshua on 8/17/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import Foundation


protocol PlantDelegate {
    func savePlant()
    func setHeaderAs(imageID: String)
}
