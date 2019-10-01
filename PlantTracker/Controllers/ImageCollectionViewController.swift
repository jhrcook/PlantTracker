//
//  ImageCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/31/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os
import SnapKit

private let reuseIdentifier = "image"

class ImageCollectionViewController: UICollectionViewController {
    
    /// An array of `UIImage` objects to display.
    var images = [UIImage]()
    
    /// A label that apppears if there are no images.
    /// - TODO: use closure syntax to set it up at declaration
    /// - TODO: make private and lazy
    var noImagesLabel = UILabel()
    
    /// The currently selected index.
    ///
    /// This is mainly used for interactions with a `ImagePagingCollectionViewController`
    var currentIndex = 0
    
    /// The `Plant` object whose images are being displayed.
    var plant: Plant!
    
    /// An object that manages the array of `Plant` objects.
    var plantsManager: PlantsManager!
    
    /// The number of images in a row
    /// - TODO: make private
    let numberOfImagesPerRow: CGFloat = 4.0
    
    /// The spacing between images.
    /// - TODO: make private
    let spacingBetweenCells: CGFloat = 0.5
    
    /// A `boolean` indicating whether multiple cells be selected. The selected images can then be shared or deleted.
    /// - TODO: make private
    var inMultiSelectMode = false {
        didSet {
            
            selectedImageIndices.removeAll()
            collectionView.allowsMultipleSelection = inMultiSelectMode
            navigationController?.setToolbarHidden(!inMultiSelectMode, animated: true)
            
            if inMultiSelectMode {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(exitMultiSelectionMode))
                title = "Selected \(selectedImageIndices.count) images"
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
                title = standardTitle ?? ""
            }
        }
    }
    
    /// Indices of selected images.
    /// - TODO: make private
    var selectedImageIndices = [Int]()
    
    /// The standard title to use when *not* in multi-select mode (`inMultiSelectMode == false`). It is set to the same `String` as `self.title`
    /// in `viewDidLoad()`.
    var standardTitle: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        standardTitle = title
        
        loadImages()
        setupToolbar()
    }
    
    /// Load the images of a plant into `images: [UIImage]`. It is called once during set up and when the user is done selecting new images.
    /// - TODO: experiment with loading the images in `cellForRowAt:`
    /// - TODO: make private
    func loadImages() {
        os_log("Setting up %d images.", log: Log.imageCollectionVC, type: .info, plant.images.count)
        images.removeAll(keepingCapacity: true)
        for imageID in plant.images {
            if let image = UIImage(contentsOfFile: getFilePathWith(id: imageID)) { images.append(image) }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if images.count == 0 {
            noImagesLabel = UILabel()
            view.addSubview(noImagesLabel)
            noImagesLabel.snp.makeConstraints { make in
                make.centerX.equalTo(view)
                make.centerY.equalTo(view)
            }

            noImagesLabel.text = "No images"
        } else {
            noImagesLabel.removeFromSuperview()
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if inMultiSelectMode { inMultiSelectMode = false }
    }
    
    /// An action sheet is presented to imort or edit images.
    @objc func editButtonTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Import images", style: .default, handler: addImages))
        ac.addAction(UIAlertAction(title: "Edit images", style: .default, handler: selectMultipleImages))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}



// MARK: UICollectionViewDataSource

extension ImageCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        cell.imageView.contentMode = .scaleAspectFill
        
        cell.shadingView.isHidden = true
        cell.borderView.isHidden = true
        cell.shadingView.backgroundColor = .white
        cell.shadingView.alpha = 0.25
        cell.borderView.layer.borderWidth = 3
        cell.borderView.backgroundColor = .clear
        cell.borderView.layer.borderColor = UIColor(alpha: 1.0, red: 52, green: 110, blue: 216).cgColor
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("selected image at %d.", log: Log.imageCollectionVC, type: .info, indexPath.item)
        currentIndex = indexPath.item
        
        
        if inMultiSelectMode {
            if let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) as? ImageCollectionViewCell {
                print("selected index \(indexPath.item) - cell is selected: \(cell.isSelected)")
                selectedImageIndices.append(indexPath.item)
                cell.shadingView.isHidden = false
                cell.borderView.isHidden = false
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if inMultiSelectMode {
            if let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) as? ImageCollectionViewCell {
                print("deselected index \(indexPath.item) - cell is selected: \(cell.isSelected)")
                cell.shadingView.isHidden = true
                cell.borderView.isHidden = true
                selectedImageIndices = selectedImageIndices.filter() { $0 != indexPath.item }
            }
        }
    }

}


// MARK: AssetPickerFinishedSelectingDelegate

extension ImageCollectionViewController: AssetPickerFinishedSelectingDelegate {
    
    /// Add images to the plant using `PlantAssetsPickerViewController`. `self` is set as the delegate.
    /// - parameter alert: The alert action that called the function (not used).
    @objc func addImages(_ alert: UIAlertAction) {
        let imagePicker = PlantAssetsPickerViewController()
        imagePicker.plant = plant
        imagePicker.didFinishDelegate = self
        
        os_log("Presenting asset image picker.", log: Log.detailLibraryVC, type: .info)
        
        present(imagePicker, animated: true)
    }
    
    /// This function is called when the user is done selecting images. It saves the plants,
    /// loads the images into `images: [UIImage]` and reloads the data.
    /// - parameter assetPicker: The `PlantAssetsPickerViewController` that called the function.
    func didFinishSelecting(assetPicker: PlantAssetsPickerViewController) {
        os_log("AssetPicker did finish selecting.", log: Log.detailLibraryVC, type: .info)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.plantsManager.savePlants()
            self?.loadImages()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
}



// MARK: Multi-select mode

extension ImageCollectionViewController {
    
    /// Organize the tool bar for multi-select mode. The tool bar will have a trash and a share icons for deleting or sharing images.
    func setupToolbar() {
        let trashToolbarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedImages))
        let shareToolbarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelectedImages))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [shareToolbarButton, spacer, trashToolbarButton]
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    /// Called to turn on miltu-select mode by setting `inMultiSelectMode` to `true`.
    /// - parameter alert: The alert action that called the function (not used).
    @objc func selectMultipleImages(_ alert: UIAlertAction) {
        inMultiSelectMode = true
    }
    
    /// Delete the currently selected images. The images are deleted from `images: [UIImage]`, the `plant.images: [String]`, removed from disk
    /// And from the collection view. The deletion is animated by calling `collectionView.deleteItems(at: [IndexPath])`.
    /// - parameter alert: The alert action that called the function (not used).
    @objc func deleteSelectedImages(_ alert: UIAlertAction) {
        if selectedImageIndices.count > 0 {
            let ac = UIAlertController(title: "Delete \(selectedImageIndices.count) images?", message: "Are you sure you want to delete the selected images?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                for ind in self!.selectedImageIndices.sorted().reversed() {
                    self?.images.remove(at: ind)
                    let uuid = self!.plant.images[ind]
                    self?.plant.deleteImage(with: uuid)
                    self?.collectionView.deleteItems(at: [IndexPath(item: ind, section: 0)])
                }
                self?.plantsManager.savePlants()
                self?.selectedImageIndices.removeAll()
            })
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "No images selected.", message: "Select images by tapping on them.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    /// Share the currently selected images using the satandard `UIActivityViewController(activityItems:applicationActivities:)`.
    /// - parameter alert: The alert action that called the function (not used).
    @objc func shareSelectedImages(_ alert: UIAlertAction) {
        if selectedImageIndices.count > 0 {
            var imagesToShare = [UIImage]()
            for ind in selectedImageIndices {
                imagesToShare.append(images[ind])
            }
            let activityVC = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
            present(activityVC, animated: true)
        } else {
            let ac = UIAlertController(title: "No images selected.", message: "Select images by tapping on them.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    /// Deactivate multi-select mode by setting `inMultiSelectMode` to `false`.
    @objc func exitMultiSelectionMode(_ alert: UIAlertAction) {
        inMultiSelectMode = false
        collectionView.reloadData()
    }
    
    
    
}



// MARK: UICollectionViewDelegateFlowLayout

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / numberOfImagesPerRow - (spacingBetweenCells * numberOfImagesPerRow)
        return CGSize(width: width, height: width)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
}



// MARK: Segues

extension ImageCollectionViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // block segue to paging view controller when in editing mode
        if inMultiSelectMode && identifier == "toPagingViewCollection" {
            return false
        }
        return true
    }
    
    
    // segue to paging view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ImagePagingCollectionViewController{
            
            os_log("Preparing segue to `ImagePagingCollectionViewController`.", log: Log.imageCollectionVC, type: .info)
            
            // pass data
            destinationVC.images = images
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                destinationVC.startingIndex = indexPath.item
            }
            
            // container delegate to pass information backwards
            destinationVC.containerDelegate = self
            destinationVC.saveEditsDelegate = self
            
            // set delegates
            self.navigationController?.delegate = destinationVC.transitionController
            
            destinationVC.transitionController.fromDelegate = self
            destinationVC.transitionController.toDelegate = destinationVC
        }
    }
}



// MARK: ZoomAnimatorDelegate

extension ImageCollectionViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        // code to run before the transition animation
        os_log("`ZoomAnimatorDelegate` is starting.", log: Log.imageCollectionVC, type: .info)
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        // code to run after the transition animation
        os_log("`ZoomAnimatorDelegate` is finishing.", log: Log.imageCollectionVC, type: .info)
    }
    
    /// Retrieve the cell at `currentIndex` for a zoom animation.
    /// - parameter zoomAnimator: The `ZoomAnimator` object organizing the transition animation.
    func getCell(for zoomAnimator: ZoomAnimator) -> ImageCollectionViewCell? {
        
        let indexPath = zoomAnimator.isPresenting ? collectionView.indexPathsForSelectedItems?.first : IndexPath(item: currentIndex, section: 0)
        
        if let cell = collectionView.cellForItem(at: indexPath!) as? ImageCollectionViewCell {
            return cell
        } else {
            return nil
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        if let cell = getCell(for: zoomAnimator) {
            return cell.imageView
        }
        return nil
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        if let cell = getCell(for: zoomAnimator) {
            return cell.contentView.convert(cell.imageView.frame, to: view)
        }
        return nil
    }
    
    
}



// MARK: ImagePagingCollectionViewControllerDelegate

extension ImageCollectionViewController: ImagePagingCollectionViewControllerDelegate {
    
    /// Respond to a change in index of the current image when in the paging view.
    /// - parameters:
    ///     - containerViewController: The view controller that called the function.
    ///     - currentIndex: The index of the paging view controller. `self.currentIndex` is assigned this value to stay in sync.
    ///
    /// - TODO: change name of first parameter to `imagePagingCollectionViewController`
    func containerViewController(_ containerViewController: ImagePagingCollectionViewController, indexDidChangeTo currentIndex: Int) {
        self.currentIndex = currentIndex
        os_log("Setting new current index value.", log: Log.imageCollectionVC, type: .info)
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredVertically, animated: false)
    }
    
    /// A notification from the `ImagePagingCollectionViewController` to delete the image at an index.
    /// - parameter index: Index at which to delete the image.
    ///
    /// - Note: The image is already deleted from the plant, erased from disk, and removed from `images: [UIImage]`. The only task to be done, here,
    /// is to remove the image from the collection view using `collectionView.deleteItems(at: [IndexPath])`.
    ///
    /// - TODO: add first paramter as `_ containerViewController: ImagePagingCollectionViewController`
    func removeCell(at index: Int) {
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}



// MARK: EditedImageDelegate

extension ImageCollectionViewController: EditedImageDelegate {
    
    /// Set the profile or the `plant: Plant` using the image at the specified index of `images: [UIImage]`.
    /// - parameter index: index of `images: [UIImage]` for which to pull the image for the profile image.
    func setProfileAs(imageAt index: Int) {
        plant.profileImage = plant.images[index]
        plantsManager.savePlants()
    }
    
    /// Delete an image from `plant: Plant` at the specific index.
    /// - parameter index: index of `images: [UIImage]` and the `plant: Plant` object's image array.
    func deleteImage(at index: Int) {
        images.remove(at: index)
        let imageUUID = plant.images[index]
        plant.deleteImage(with: imageUUID)
        plantsManager.savePlants()
    }
    
    /// Save changes to an image at the specific index.
    /// - parameter image: The new (edited) image to replace the old one with.
    /// - parameter index: The index of the image being replaced.
    ///
    /// - Note: The image is *replaced*, not appended. Therefore, it retains the same file name and UUID. Therefore, anything that
    /// references this image (eg. the header image) will be affected by the change. 
    func save(image: UIImage, withIndex index: Int) {
        let fileURL = getFileURLWith(id: plant.images[index])
        images[index] = image
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            cell.imageView.image = image
        }
        
        // save image to original file's name
        DispatchQueue.global(qos: .userInitiated).async {
            if let jpegData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try jpegData.write(to: fileURL)
                } catch {
                    os_log("Error when saving compressed image. Error message: %@.", log: Log.imageCollectionVC, type: .error, error.localizedDescription)
                }
            } else {
                os_log("Unable to compress the image.", log: Log.imageCollectionVC, type: .error)
            }
        }
        
        plantsManager.savePlants()
        
    }
    
    
}
