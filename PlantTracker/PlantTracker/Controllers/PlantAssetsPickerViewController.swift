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
        print("Need permission to access photo library.")
    }
    
    
    func setup() {
        
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
            print("value not entered for \"Image Quality\" setting.")
        }
        imageOptions.version = .current
        imageOptions.isSynchronous = false
        imageOptions.resizeMode = .exact
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
        let assetSize = CGSize(width: Double(asset.pixelWidth), height: Double(asset.pixelHeight))
        let requestIndex = imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: addImageToPlant)
        assetTracker.add(requestIndex: Int(requestIndex), withIndexPathItem: indexPath.item)
        print("saving request ID '\(requestIndex)' to index path '\(indexPath.item)'")
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
        if let uuid = assetTracker.uuidFrom(indexPathItem: indexPath.item) {
            print("deleting image uuid '\(uuid)' at index path '\(indexPath.item)'")
            plant.deleteImage(at: uuid)
        } else {
            assetTracker.didNotDeleteAtRequestIndex.append(indexPath.item)
        }
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for index in assetTracker.didNotDeleteAtRequestIndex {
            if let uuid = assetTracker.uuidFrom(indexPathItem: index) {
                print("deleting image uuid '\(uuid)' at index path '\(index)'")
                plant.deleteImage(at: uuid)
            }
        }
        assetTracker.reset()
        if let delegate = plantsSaveDelegate { delegate.savePlants() }
        if let delegate = didFinishDelegate { delegate.didFinishSelecting(assetPicker: self) }
    }
    
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        print("user canceled asset getting")
        if let allUUIDs = assetTracker.allUUIDs() {
            for uuid in allUUIDs {
                print("deleting UUID '\(uuid)'")
                plant.deleteImage(at: uuid)
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
                print("saving image: \(uuid)")
                let imageURL = getFileURLWith(id: uuid)
                
                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    try? jpegData.write(to: imageURL)
                }
                self?.plant.images.append(uuid)
                if let info = info, let requestIndex = info["PHImageResultRequestIDKey"] as? Int {
                    print("setting uuid '\(uuid)' as request index '\(requestIndex)'")
                    self?.assetTracker.add(uuid: uuid, withRequestIndex: requestIndex)
                } else {
                    print("failed to set request index for image UUID, dumping `info`:")
                    print("-----------------")
                    if let info = info { print(info) }
                    print("-----------------")
                }
            }
        }
    }
    
}
