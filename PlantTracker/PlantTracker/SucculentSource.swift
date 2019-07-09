//
//  SucculentSource.swift
//  PlantTracker
//
//  Created by Joshua on 7/8/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class SucculentSource: NSObject, Codable {
    var name: String
    var location: String?
    
    init(name: String) {
        self.name = name
    }
}
