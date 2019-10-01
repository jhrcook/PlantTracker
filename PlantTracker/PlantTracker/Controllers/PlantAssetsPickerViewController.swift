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

/// A protocol to create a delegate that is called when the user is done selecting images.
protocol AssetPickerFinishedSelectingDelegate {
    func didFinishSelecting(assetPicker: PlantAssetsPickerViewController)
}

/// The controller for picking images from the user's library.
class PlantAssetsPickerViewController: AssetsPickerViewController, AssetsPickerViewControllerDelegate {

    /// A manager of the images selected and de-selected. It ensures that the selected images are requested
    /// and written to disk.
    var assetTracker = AssetIndexIDTracker()
    
    /// `Plant` object to select images for.
    var plant: Plant!
    
    /// Delegate that gets called when the user is done selecting images.
    var didFinishDelegate: AssetPickerFinishedSelectingDelegate?
    
    /// Options for fetching images from the user's library. This controller only requests images.
    /// - TODO: make private
    let fetchOptions = PHFetchOptions()
    
    /// A manager required for getting images from a user's library.
    /// - TODO: make private
    let imageManager = PHImageManager.default()
    
    /// Options for the images requested from a user's library.
    /// - TODO: make private
    let imageOptions = PHImageRequestOptions()
    
    /// - TODO: can I get rid of this and replace it with an `init()` that calls this with `nil` values?
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
    
    /// Log if the controller cannot get access to the photos library.
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        os_log("Need permission to access photo library.", log: Log.assetPickerVC, type: .error)
    }
    
    /// Set up the image picker. This is called upon initialization and need only be called once.
    /// - TODO: make private
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
    
    /**
     Called when the user *selects* an image. The full image is requested and saved to the plant's images.
     - parameters:
        - controller: The `AssetsPickerViewController` that is being used to select images.
        - asset: The asset (image) seleted by the user to be requested.
        - indexPath: The index location of the asset.
     
     - Important: The fullfillment of the asset request is done asynchronously by `imageManager`. The request returns a task ID. This ID is saved to the
    `assetTracker` and used to connect the users selection with the final `UIImage`. The index of the selection is also stored so that the image can be deleted
     if the user deselects the image.
     */
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
        os_log("Image selected at index %d.", log: Log.assetPickerVC, type: .info, indexPath.item)
        let assetSize = CGSize(width: Double(asset.pixelWidth), height: Double(asset.pixelHeight))
        let requestIndex = imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: addImageToPlant)
        assetTracker.add(requestIndex: Int(requestIndex), withIndexPathItem: indexPath.item)
        os_log("saving request ID '%d' to index path '%d'", log: Log.assetPickerVC, type: .info, requestIndex, indexPath.item)
    }
    
    /**
     Called when the user *deselects* an image.
     - parameters:
        - controller: The `AssetsPickerViewController` that is being used to select images.
        - asset: The asset (image) deseleted by the user.
        - indexPath: The index location of the asset.
     
     - Important: The `assetTracker` is used to ensure that the image selected is deleted and removed from the plant's array of image file names.
     */
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
        if let uuid = assetTracker.uuidFrom(indexPathItem: indexPath.item) {
            os_log("deleting image uuid '%public}@' at index path '%d'", log: Log.assetPickerVC, type: .info, uuid, indexPath.item)
            plant.deleteImage(with: uuid)
        } else {
            assetTracker.didNotDeleteAtRequestIndex.append(indexPath.item)
        }
    }
    
    /// Called when the user is done editing and wants to save their selections.
    /// - parameters:
    ///     - controller: The `AssetsPickerViewController` that is being used to select images.
    ///     - assets: All of the assets (images) selected by the user.
    ///
    /// All images should have already been saved, but this is double checked.
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        os_log("Finished selecting %d images.", log: Log.assetPickerVC, type: .info, assets.count)
        for index in assetTracker.didNotDeleteAtRequestIndex {
            if let uuid = assetTracker.uuidFrom(indexPathItem: index) {
                os_log("deleting image uuid '%{public}@' at index path '%d'", log: Log.assetPickerVC, type: .info, uuid, index)
                plant.deleteImage(with: uuid)
            }
        }
        assetTracker.reset()
        if let delegate = didFinishDelegate { delegate.didFinishSelecting(assetPicker: self) }
    }
    
    /// Called when the user canels their image picker session. The `assetTracker` is used to ensre that all images previously saved are deleted.
    /// - parameter controller: The `AssetsPickerViewController` that is being used to select images.
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
    
    /**
     Write a `UIImage` to disk as a JPEG and save the UUID to the plant's array of images.
     - parameters:
        - image: The image to write to disk (as a JPEG)
        - info: Information about the image returned when the asset was fetched from the user's library. This information contains the tracking ID which is
     then linked to the images UUID in the `assetTracker`.
     
     - Note: The images are saved in a background thread using GCD.
     */
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
