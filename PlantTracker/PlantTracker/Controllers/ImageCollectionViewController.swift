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
    
    var images = [UIImage]()
    
    var noImagesLabel = UILabel()
    
    var currentIndex = 0
    
    var plant: Plant!
    var plantsManager: PlantsManager!
    
    let numberOfImagesPerRow: CGFloat = 4.0
    let spacingBetweenCells: CGFloat = 0.5
    
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
    var selectedImageIndices = [Int]()
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
    
    @objc func addImages(_ alert: UIAlertAction) {
        let imagePicker = PlantAssetsPickerViewController()
        imagePicker.plant = plant
        imagePicker.didFinishDelegate = self
        
        os_log("Presenting asset image picker.", log: Log.detailLibraryVC, type: .info)
        
        present(imagePicker, animated: true)
    }
    
    
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



// for multi-selection editing

extension ImageCollectionViewController {
    
    func setupToolbar() {
        let trashToolbarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedImages))
        let shareToolbarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelectedImages))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [shareToolbarButton, spacer, trashToolbarButton]
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
    @objc func selectMultipleImages(_ alert: UIAlertAction) {
        inMultiSelectMode = true
    }
    
    
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



// MARK: segues

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
    func containerViewController(_ containerViewController: ImagePagingCollectionViewController, indexDidChangeTo currentIndex: Int) {
        self.currentIndex = currentIndex
        os_log("Setting new current index value.", log: Log.imageCollectionVC, type: .info)
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredVertically, animated: false)
    }
    
    func removeCell(at index: Int) {
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}



// MARK: SaveEditedImageDelegate

extension ImageCollectionViewController: EditedImageDelegate {
    func setProfileAs(imageAt index: Int) {
        plant.profileImage = plant.images[index]
        plantsManager.savePlants()
    }
    
    func deleteImage(at index: Int) {
        images.remove(at: index)
        let imageUUID = plant.images[index]
        plant.deleteImage(with: imageUUID)
        plantsManager.savePlants()
    }
    
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
