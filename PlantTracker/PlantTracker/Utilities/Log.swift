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
    static let detailLibraryGeneralInfoVC = OSLog(subsystem: subsystem, category: "GeneralPlantInformationTableViewController")
    static let imageCollectionVC = OSLog(subsystem: subsystem, category: "ImageCollectionViewController")
    static let pagingImageVC = OSLog(subsystem: subsystem, category: "ImagePagingCollectionViewController")
    static let assetPickerVC = OSLog(subsystem: subsystem, category: "PlantAssetsPickerViewController")
    static let zoomAnimator = OSLog(subsystem: subsystem, category: "ZoomAnimator")
    
    static let plantsObject = OSLog(subsystem: subsystem, category: "Plant")
    static let plantsManager = OSLog(subsystem: subsystem, category: "PlantManager")
    static let editPlantManager = OSLog(subsystem: subsystem, category: "EditPlantLevelManager")
}
