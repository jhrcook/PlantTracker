//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class Plant: NSObject, Codable {
    var scientificName: String?
    var commonName: String?
    
    var image: String?
    
    init(scientificName: String?, commonName: String) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
    
    func simpleDescription() {
        print("\(scientificName ?? "untitled") (\(commonName ?? "untitled"))")
    }
}
