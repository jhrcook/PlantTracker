//
//  AssetIndexIDTracker.swift
//  PlantTracker
//
//  Created by Joshua on 8/4/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import Foundation
import UIKit

struct AssetIndexIDTracker {
    
    /// The dictionary relating the index of the asset fetch request to a UUID of the image.
    /// - TODO: make private
    var requestIndexToUUID = [Int: String]()
    
    /// The dictionary relating the index of the image in the user's library to the asset fetch request.
    /// - TODO: make private
    var indexPathToRequestIndex = [Int: Int]()
    
    /// An array of `Int` containing the asset fetch request IDs that have not been deleted.
    /// - TODO: make private
    var didNotDeleteAtRequestIndex = [Int]()
    
    /// Retrieve the UUID for an image at an index in the user's library.
    /// - parameter indexPathItem: The index of the image in the user's library.
    func uuidFrom(indexPathItem: Int) -> String? {
        if let requestIndex = indexPathToRequestIndex[indexPathItem] {
            if let uuid = requestIndexToUUID[requestIndex] {
                return uuid }
        }
        return nil
    }
    
    /// Get all UUIDs for the images selected by the user.
    /// - returns: An array of `String` if any UUIDs exist, else `nil`
    func allUUIDs() -> [String]? {
        if requestIndexToUUID.count > 0 {
            let uuids = requestIndexToUUID.values.map { String($0) }
            return(uuids)
        } else {
            return nil
        }
    }
    
    /// Add an UUID for an ID from an asset fetch request.
    /// - parameters:
    ///     - uuid: A string of a `UUID`object.
    ///     - requestIndex: The ID returned for a asset fetch request.
    mutating func add(uuid: String, withRequestIndex requestIndex: Int) {
        requestIndexToUUID[requestIndex] = uuid
    }
    
    /// Add an ID from an asset fetch request for the index of the image in the user's library.
    /// - parameters:
    ///     - requestIndex: The ID returned for a asset fetch request.
    ///     - indexPathItem: The index of the image in the user's library.
    mutating func add(requestIndex: Int, withIndexPathItem indexPathItem: Int) {
        indexPathToRequestIndex[indexPathItem] = requestIndex
    }
    
    /// Reset the asset tracker object.
    mutating func reset() {
        requestIndexToUUID.removeAll()
        indexPathToRequestIndex.removeAll()
        didNotDeleteAtRequestIndex.removeAll()
    }
}
