//
//  ImageCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/31/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os

private let reuseIdentifier = "image"

class ImageCollectionViewController: UICollectionViewController {
    
    var imageIDs = [String]()
    var images = [UIImage]()
    
    var currentIndex = 0
    
    let numberOfImagesPerRow: CGFloat = 4.0
    let spacingBetweenCells: CGFloat = 0.5
    
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
        
        // load images
        os_log("Setting up %d images.", log: Log.imageCollectionVC, type: .info, imageIDs.count)
        for imageID in imageIDs {
            if let image = UIImage(contentsOfFile: getFilePathWith(id: imageID)) { images.append(image) }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("selected image at %d.", log: Log.imageCollectionVC, type: .info, indexPath.item)
        currentIndex = indexPath.item
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



// MARK: segue

extension ImageCollectionViewController {
    
    // segue to paging view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ImagePagingCollectionViewController{
            
            os_log("Preparing segue to `ImagePagingCollectionViewController`.", log: Log.imageCollectionVC, type: .info)
            
            // pass data
            destinationViewController.images = images
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                destinationViewController.startingIndex = indexPath.item
            }
            
            // container delegate to pass information backwards
            destinationViewController.containerDelegate = self
            
            // set delegates
            self.navigationController?.delegate = destinationViewController.transitionController
            
            destinationViewController.transitionController.fromDelegate = self
            destinationViewController.transitionController.toDelegate = destinationViewController
        }
    }
}



// MARK: ZoomAnimatorDelegate

extension ImageCollectionViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        // code to run before the transition animation
        os_log("`ZoomAnimatorDelegate` is running `transitionWillStartWith(zoomAnimator:)`.", log: Log.imageCollectionVC, type: .info)
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        // code to run after the transition animation
        os_log("`ZoomAnimatorDelegate` is running `transitionDidEndWith(zoomAnimator:)`.", log: Log.imageCollectionVC, type: .info)
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
}
