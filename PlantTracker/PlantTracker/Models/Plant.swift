//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class Plant: NSObject, Codable {

    // unique, unchanging identifier
    let uuid = UUID().uuidString
    
    // naming
    var scientificName: String?
    var commonName: String?
    
    // images
    var images = [String]()
    var favoriteImages = [String]()
    var profileImage: String?
    var smallRoundProfileImage: String?
    
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
    
    func deleteImage(at imageUUID: String) {
        let filePath = getFilePathWith(id: imageUUID)
        do {
            let fileManager = FileManager()
            try fileManager.removeItem(atPath: filePath)
            print("deleted image: \(filePath)")
        } catch {
            print("Unable to delete image: \(filePath)")
        }
        
        // remove all cases where the image UUID is used
        images.removeAll(where: { $0 == imageUUID })
        favoriteImages.removeAll(where: { $0 == imageUUID })
        if profileImage == imageUUID { profileImage = nil }
        if smallRoundProfileImage == imageUUID { smallRoundProfileImage = nil }
    }
    
    func deleteAllImages() {
        // delete files
        for image in images {
            deleteImage(at: image)
        }
        if let image = smallRoundProfileImage { deleteImage(at: image) }

        // empty arrays
        images.removeAll()
        favoriteImages.removeAll()
        profileImage = nil
        smallRoundProfileImage = nil
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
    
    
    func printableGrowingSeason() -> String {
        return growingSeason.map { $0.rawValue }.joined(separator: ", ")
    }
    
    func printableDormantSeason() -> String {
        return dormantSeason.map { $0.rawValue }.joined(separator: ", ")
    }
    
    func printableWatering() -> String {
        return watering.map { $0.rawValue }.joined(separator: ", ")
    }
    
    func printableLighting() -> String {
        return lighting.map { $0.rawValue }.joined(separator: ", ")
    }
    
    
}


// ---- Enums for information attributes ---- //

enum Season: String, Codable {
    case summer, fall, winter, spring
}

enum DifficultyLevel: Int, Codable {
    case easy = 1, medium, hard
}

enum WateringLevel: String, Codable {
    case veryDry = "very dry", dry, moist, wet
}

enum LightLevel: String, Codable {
    case allDay = "all day", morning, afternoon, filtered, indirect, shade, low
}

// ---- ---- //


class Seller: Codable {
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

