//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class Plant: NSObject {

    // unique, unchanging identifier
    let uuid = UUID().uuidString
    
    // naming
    var scientificName: String?
    var commonName: String?
    
    // images
    var images = [String]()
    var favoriteImages = [String]()
    var profileImage: String?
    
    // information
    var growingSeason = [Season]()
    var dormantSeason = [Season]()
    var difficulty: DifficultyLevel?
    var watering = [WateringLevel]()
    var lighting = [LightLevel]()
    
    // purchase information
    var purchaseDate: Date?
    var purchasedFrom: Seller?
    
    // notes
    var notes = ""

    
    // ---- Initializers ---- //
    init(scientificName: String?, commonName: String?) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
    
    // ---- Deleting images ---- //
    // make sure to remove the file from the phone
    
    func deleteImage(imageName: String) {
        // delete image
    }
    
    func deleteAllImages() {
        for image in images {
            deleteImage(imageName: image)
        }
    }
    
    func printSimpleDescription() {
        if let sn = scientificName, let cn = commonName {
            print("\(sn) - \(cn)")
        } else if scientificName != nil {
            print(scientificName!)
        } else if commonName != nil {
            print(commonName!)
        }
    }
    
    func bestSingleImage() -> String? {
        if profileImage != nil { return profileImage! }
        if favoriteImages.count > 0 { return favoriteImages[0] }
        if images.count > 0 { return images[0] }
        return nil
    }
    
}


// ---- Enums for information attributes ---- //

enum Season: String {
    case summer, fall, winter, spring
}

enum DifficultyLevel: Int {
    case easy = 1, medium, hard
}

enum WateringLevel: String {
    case veryDry = "very dry", dry, moist, wet
}

enum LightLevel: String {
    case allDay = "all day", morning, afternoon, filtered, indirect, shade, low
}

// ---- ---- //


class Seller {
    var name: String?
    var business: String?
    
    init(name: String?) {
        self.name = name
    }
    
    convenience init(name: String?, business: String?) {
        self.init(name: name)
        self.business = business
    }
    
    convenience init(business: String?) {
        self.init(name: nil)
        self.business = business
    }
}
