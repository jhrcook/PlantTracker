//
//  Log.swift
//  PlantTracker
//
//  Created by Joshua on 8/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import Foundation
import os

private let subsystem = "com.joshdoesathing.PlantTracker"

struct Log {
    static let plantLibraryTableVC = OSLog(subsystem: subsystem, category: "PlantLibraryTableViewController")
    static let detailLibraryVC = OSLog(subsystem: subsystem, category: "LibraryDetailViewController")
    static let imageCollectionVC = OSLog(subsystem: subsystem, category: "ImageCollectionViewController")
}
