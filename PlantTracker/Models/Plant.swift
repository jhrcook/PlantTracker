//
//  Plant.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os


class Plant: NSObject, Codable {

    /// A unique, unchanging identifier for the plant.
    let uuid = UUID().uuidString
    
    /// The scientific name of the plant.
    var scientificName: String?
    
    /// The common name of the plant.
    var commonName: String?
    
    /// All of the images for the plant.
    var images = [String]()
    
    /// Images that have been specifically "Favorited" by the user.
    var favoriteImages = [String]()
    
    /// The profile image to use for the plant.
    var profileImage: String?
    
    /// The small, round image to use for an icon image.
    var smallRoundProfileImage: String?
    
    /// The growing season(s) of the plant.
    var growingSeason = [Season]()
    /// The dormant season(s) of the plant.
    var dormantSeason = [Season]()
    /// The difficulty level of the plant.
    var difficulty: DifficultyLevel?
    /// The water level(s) the plant can tolerate.
    var watering = [WateringLevel]()
    /// The lighting level(s) the plant can tolerate.
    var lighting = [LightLevel]()
    
    /// Date of purchasing the plant.
    var purchaseDate: Date?
    /// From whom/where the plant was purchased.
    var purchasedFrom: Seller?
    
    /// Notes about the plant.
    var notes = ""

    
    /// Initialize a plant object with a scientific and common name.
    init(scientificName: String?, commonName: String?) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
    
    /// Delete an image from a plant. The `images: [UIImage]` array just holds the UUIDs of the images. The file must specifically be
    /// deleted using a `FileManager`.
    /// - parameter imageUUID: The UUID of the image to be deleted. It is deleted from disk and all properties of the plant object that
    /// hold image UUIDs.
    func deleteImage(with imageUUID: String) {
        let filePath = getFilePathWith(id: imageUUID)
        do {
            let fileManager = FileManager()
            try fileManager.removeItem(atPath: filePath)
            os_log("Deleted image: %@", log: Log.plantsObject, type: .default, filePath)
        } catch {
            os_log("Unable to delete image: %@", log: Log.plantsObject, type: .default, filePath)
        }
        
        // remove all cases where the image UUID is used
        images.removeAll(where: { $0 == imageUUID })
        favoriteImages.removeAll(where: { $0 == imageUUID })
        if profileImage == imageUUID { profileImage = nil }
        if smallRoundProfileImage == imageUUID { smallRoundProfileImage = nil }
    }
    
    /// Delete all images from a plant.
    ///
    /// - Important: Make sure to offer the user a second chance before running this destructive task.
    func deleteAllImages() {
        // delete files
        for image in images {
            deleteImage(with: image)
        }
        if let image = smallRoundProfileImage { deleteImage(with: image) }

        // empty arrays
        images.removeAll()
        favoriteImages.removeAll()
        profileImage = nil
        smallRoundProfileImage = nil
    }
    
    
    /// Prints a simple description of the plant.
    func printSimpleDescription() {
        if let sn = scientificName, let cn = commonName {
            print("\(sn) - \(cn)")
        } else if scientificName != nil {
            print(scientificName!)
        } else if commonName != nil {
            print(commonName!)
        }
    }
    
    /// Get the best single image for a plant. The priority is as follows: `profileImage`> the first image of `favoriteImages` > the first image in`images`.
    func bestSingleImage() -> String? {
        if profileImage != nil { return profileImage! }
        if favoriteImages.count > 0 { return favoriteImages[0] }
        if images.count > 0 { return images[0] }
        return nil
    }
    
    /// A printable statement of the `growingSeason` property.
    /// - returns: A single string with multiple growing seasons separated by commas.
    func printableGrowingSeason() -> String {
        return growingSeason.map { $0.rawValue }.joined(separator: ", ")
    }
    
    /// A printable statement of the `dormantSeason` property.
    /// - returns: A single string with multiple dormant seasons separated by commas.
    func printableDormantSeason() -> String {
        return dormantSeason.map { $0.rawValue }.joined(separator: ", ")
    }
    
    /// A printable statement of the `watering` property.
    /// - returns: A single string with multiple waering levels separated by commas.
    func printableWatering() -> String {
        return watering.map { $0.rawValue }.joined(separator: ", ")
    }
    
    /// A printable statement of the `lighting` property.
    /// - returns: A single string with lighting levels separated by commas.
    func printableLighting() -> String {
        return lighting.map { $0.rawValue }.joined(separator: ", ")
    }
    
    
}





// MARK: Enums for plant information

/// The seasons of the year.
enum Season: String, Codable, CaseIterable {
    case summer, fall, winter, spring
}

/// Three difficulty levels.
enum DifficultyLevel: String, Codable, CaseIterable {
    case easy, medium, hard
}

/// Various levels of watering from driest to wettest.
enum WateringLevel: String, Codable, CaseIterable {
    case veryDry = "very dry", dry, moist, wet
}

/// Various levels of lighting from constant/all-day to low
enum LightLevel: String, Codable, CaseIterable {
    case allDay = "all day", morning, afternoon, filtered, indirect, shade, low
}





// MARK: Seller

/// A model for a seller of plants.
class Seller: Codable {
    /// Name of seller.
    var name: String?
    /// Name of business (nursery).
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

