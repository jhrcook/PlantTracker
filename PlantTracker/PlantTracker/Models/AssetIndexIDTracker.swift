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
    
    var requestIndexToUUID = [Int: String]()
    var indexPathToRequestIndex = [Int: Int]()
    var didNotDeleteAtRequestIndex = [Int]()
    
    func uuidFrom(indexPathItem: Int) -> String? {
        if let requestIndex = indexPathToRequestIndex[indexPathItem] {
            if let uuid = requestIndexToUUID[requestIndex] {
                return uuid }
        }
        return nil
    }
    
    func allUUIDs() -> [String]? {
        if requestIndexToUUID.count > 0 {
            let uuids = requestIndexToUUID.values.map { String($0) }
            return(uuids)
        } else {
            return nil
        }
    }
    
    mutating func add(uuid: String, withRequestIndex requestIndex: Int) {
        requestIndexToUUID[requestIndex] = uuid
    }
    
    mutating func add(requestIndex: Int, withIndexPathItem indexPathItem: Int) {
        indexPathToRequestIndex[indexPathItem] = requestIndex
    }
    
    mutating func reset() {
        requestIndexToUUID.removeAll()
        indexPathToRequestIndex.removeAll()
        didNotDeleteAtRequestIndex.removeAll()
    }
}
