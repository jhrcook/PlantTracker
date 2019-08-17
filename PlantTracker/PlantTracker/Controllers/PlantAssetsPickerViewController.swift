//
//  PlantAssetsPickerViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/11/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import AssetsPickerViewController
import Photos
import os


protocol AssetPickerFinishedSelectingDelegate {
    func didFinishSelecting(assetPicker: PlantAssetsPickerViewController)
}

class PlantAssetsPickerViewController: AssetsPickerViewController, AssetsPickerViewControllerDelegate {

    var plant: Plant!
    var assetTracker = AssetIndexIDTracker()
    var plantsSaveDelegate: PlantsDelegate?
    var didFinishDelegate: AssetPickerFinishedSelectingDelegate?
    
    let fetchOptions = PHFetchOptions()
    
    let imageManager = PHImageManager.default()
    let imageOptions = PHImageRequestOptions()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        os_log("Need permission to access photo library.", log: Log.assetPickerVC, type: .error)
    }
    
    
    func setup() {
        os_log("Setting up asset picker", log: Log.assetPickerVC, type: .info)
        
        pickerDelegate = self
        
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        pickerConfig.assetFetchOptions = [
            .album: fetchOptions,
            .smartAlbum: fetchOptions
        ]
        
        let defaults = UserDefaults.standard
        switch defaults.string(forKey: "image quality") {
        case "high":
            imageOptions.deliveryMode = .highQualityFormat
        case "medium":
            imageOptions.deliveryMode = .opportunistic
        case "low":
            imageOptions.deliveryMode = .fastFormat
        default:
            imageOptions.deliveryMode = .highQualityFormat
            os_log("No value not selected for 'Image Quality' in Settings.", log: Log.assetPickerVC, type: .info)
        }
        imageOptions.version = .current
        imageOptions.isSynchronous = false
        imageOptions.resizeMode = .exact
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
        os_log("Image selected at index %d.", log: Log.assetPickerVC, type: .info, indexPath.item)
        let assetSize = CGSize(width: Double(asset.pixelWidth), height: Double(asset.pixelHeight))
        let requestIndex = imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: addImageToPlant)
        assetTracker.add(requestIndex: Int(requestIndex), withIndexPathItem: indexPath.item)
        os_log("saving request ID '%d' to index path '%d'", log: Log.assetPickerVC, type: .info, requestIndex, indexPath.item)
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
        if let uuid = assetTracker.uuidFrom(indexPathItem: indexPath.item) {
            os_log("deleting image uuid '%public}@' at index path '%d'", log: Log.assetPickerVC, type: .info, uuid, indexPath.item)
            plant.deleteImage(with: uuid)
        } else {
            assetTracker.didNotDeleteAtRequestIndex.append(indexPath.item)
        }
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        os_log("Finished selecting %d images.", log: Log.assetPickerVC, type: .info, assets.count)
        for index in assetTracker.didNotDeleteAtRequestIndex {
            if let uuid = assetTracker.uuidFrom(indexPathItem: index) {
                os_log("deleting image uuid '%{public}@' at index path '%d'", log: Log.assetPickerVC, type: .info, uuid, index)
                plant.deleteImage(with: uuid)
            }
        }
        assetTracker.reset()
        if let delegate = plantsSaveDelegate { delegate.savePlants() }
        if let delegate = didFinishDelegate { delegate.didFinishSelecting(assetPicker: self) }
    }
    
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        os_log("User canceled asset getting", log: Log.assetPickerVC, type: .info)
        if let allUUIDs = assetTracker.allUUIDs() {
            for uuid in allUUIDs {
                os_log("Deleting UUID '%@'", log: Log.assetPickerVC, type: .info, uuid)
                plant.deleteImage(with: uuid)
            }
        }
        assetTracker.reset()
    }
    

}



extension PlantAssetsPickerViewController {
    
    func addImageToPlant(image: UIImage?, info: [AnyHashable: Any]?) {
        
        if let image = image {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let uuid = UUID().uuidString
                os_log("Saving image: '%@'", log: Log.assetPickerVC, type: .info, uuid)
                let imageURL = getFileURLWith(id: uuid)
                
                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    try? jpegData.write(to: imageURL)
                }
                self?.plant.images.append(uuid)
                if let info = info, let requestIndex = info["PHImageResultRequestIDKey"] as? Int {
                    os_log("Setting uuid '%@' as request index '%d'", log: Log.assetPickerVC, type: .info, uuid, requestIndex)
                    self?.assetTracker.add(uuid: uuid, withRequestIndex: requestIndex)
                } else {
                    os_log("Failed to set request index for image %@.", log: Log.assetPickerVC, type: .info, uuid)
                }
            }
        }
    }
    
}
