//
//  ImagePagingCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/5/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import os
import CropViewController

/// The reuse identifier `String` for the cells used in `ImagePagingCollectionViewControllerDelegate`
private let reuseIdentifier = "scrollingImageCell"

/// A protocol for communicating with the `ImageCollectionViewController` parent view controller.
protocol ImagePagingCollectionViewControllerDelegate {
    func containerViewController(_ containerViewController: ImagePagingCollectionViewController, indexDidChangeTo currentIndex: Int)
    func removeCell(at index: Int)
}

/// A protocol for relaying changes to images to the `ImagePagingCollectionViewControllerDelegate` parent view controller.
protocol EditedImageDelegate {
    func save(image: UIImage, withIndex index: Int)
    func setProfileAs(imageAt index: Int)
    func deleteImage(at index: Int)
}

/// A collection view that presents images in a horizontal paging view. Images can be edited (cropped).
class ImagePagingCollectionViewController: UICollectionViewController {

    /// The index to open to.
    var startingIndex: Int = 0
    
    /// The array of images to present.
    var images = [UIImage]()
    
    /// The index of the image currently being displayed to the user.
    var currentIndex: Int = 0 {
        didSet {
            self.title = "Image \(Int(currentIndex) + 1) of \(images.count)"
        }
    }
    
    /// Used to know if the image view of the current cell is hidden. This is required for a smooth transition from the parent
    /// image view collection. The image is hidden during the transition, and then un-hidden, afterwards.
    /// - TODO: make private
    var hideCellImageViews = false
    
    /// The controller for the zooming transition animation.
    var transitionController = ZoomTransitionController()
    
    /// Delegate to respond to changes in the image array `images: [UIImage]`.
    var containerDelegate: ImagePagingCollectionViewControllerDelegate?
    
    /// A delegate to respond to changes in a specific image in `images: [UIImage]`
    var saveEditsDelegate: EditedImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(ImagePagingViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        setupCollectionView()
        currentIndex = startingIndex
        
        // pan to dismiss
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDidPanWith(gestureRecognizer:)))
        view.addGestureRecognizer(panGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedActionButton))
    }
    
    
    // MARK: UICollectionView
    
    /// Set up the collection view so it has a horizontal paging view. This is called during `viewDidLoad()`.
    /// - TODO: make private
    func setupCollectionView() {
        
        collectionView.backgroundColor = .white
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        
        collectionView.contentSize = CGSize(width: view.frame.width * CGFloat(images.count), height: 0.0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // set initial index at `startingIndex`
        collectionView.scrollToItem(at: IndexPath(item: startingIndex, section: 0), at: .right, animated: false)
    }

}



// MARK: UICollectionViewDataSource

extension ImagePagingCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagePagingViewCell
        
        // Configure the cell
        cell.image = images[indexPath.item]
        cell.imageView.isHidden = hideCellImageViews
        
        // delegate to show/hide navigation bar on tap gesture
        cell.delegate = self
        
        return cell
    }
}



// MARK: Scroll View

extension ImagePagingCollectionViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var imageNumber = Float((scrollView.contentOffset.x - 0.5 * view.frame.width) / view.frame.width)
        imageNumber.round(.up)
        currentIndex = Int(imageNumber)
    }
    
    // change the base view controller's index, too
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        os_log("Upadting container delegate's current index. to %d", log: Log.pagingImageVC, type: .info, currentIndex)
        containerDelegate?.containerViewController(self, indexDidChangeTo: currentIndex)
    }

}



// MARK: UICollectionViewDelegateFlowLayout

extension ImagePagingCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}



// MARK: ZoomAnimatorDelegate

extension ImagePagingCollectionViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        // add code here to be run just before the transition animation
        os_log("`ZoomAnimatorDelegate` is starting.", log: Log.pagingImageVC, type: .info)
        hideCellImageViews = zoomAnimator.isPresenting
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        // add code here to be run just after the transition animation
        os_log("`ZoomAnimatorDelegate` is finishing.", log: Log.pagingImageVC, type: .info)
        hideCellImageViews = false
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
            cell.imageView.isHidden = hideCellImageViews
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
            return cell.imageView
        }
        return nil
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
            return cell.scrollView.convert(cell.imageView.frame, to: view)
        }
        return nil
    }
    
    
}



// MARK: pan gesture

extension ImagePagingCollectionViewController {
    
    /// Respond to a pan gesture to dismiss the view controller. The zoom animation transition is initiated.
    @objc func userDidPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            os_log("Dismissing pan gesture began.", log: Log.pagingImageVC, type: .info)
            
            // unhide the navigation bar if needed and turn background white
            if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
                cell.contentView.backgroundColor = .white
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
            
            transitionController.isInteractive = true
            let _ = navigationController?.popViewController(animated: true)
        case .ended:
            os_log("Dismissing pan gesture ended.", log: Log.pagingImageVC, type: .info)
            if transitionController.isInteractive {
                transitionController.isInteractive = false
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if transitionController.isInteractive {
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
    
}



// MARK: NavigationBarHidingAndShowingDelegate

extension ImagePagingCollectionViewController: PagingViewWasTappedDelegate {
    
    /// Turn the cell background black or white when a user taps on the cell
    /// - TODO: this will need a creative solution for iOS 13 Dark Mode
    func pagingViewCell(_ pagingViewCell: ImagePagingViewCell, shouldBeTurnedBlack: Bool) {
        collectionView.backgroundColor = shouldBeTurnedBlack ? UIColor.black : UIColor.white
        navigationController?.setNavigationBarHidden(shouldBeTurnedBlack, animated: true)
    }
}



// MARK: tappedRightBarButton

extension ImagePagingCollectionViewController {
    
    /// Responds to a user tappinng the Edit button the navigation bar. The options are to Edit, Share, make the header image of the `Plant` object,
    /// or Delete the image. Each of those options has a specific handler function.
    @objc func tappedActionButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Edit...", style: .default, handler: editPhoto))
        alertController.addAction(UIAlertAction(title: "Share...", style: .default, handler: shareImage))
        alertController.addAction(UIAlertAction(title: "Make header image", style: .default, handler: setHeaderImage))
        alertController.addAction(UIAlertAction(title: "Delete image", style: .destructive, handler: deleteImageTapped))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
    /// Edit a photo using a `CropViewController`.
    /// - parameter alert: The alert action that called the function.
    /// - Note: The `CropViewController` is from the swift package ['TOCropViewController'](https://github.com/TimOliver/TOCropViewController).
    ///
    /// - TODO: make private
    func editPhoto(_ alert: UIAlertAction) {
        let image = images[currentIndex]
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    
    /// Share an image using the standard `UIActivityViewController`.
    /// - parameter alert: The alert action that called the function.
    ///
    /// - TODO: make private
    func shareImage(_ alert: UIAlertAction) {
        let image = images[currentIndex]
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    /// Set the header image of the plant by calling `EditedImageDelegate.setProfileAs(imageAt:)`
    /// - parameter alert: The alert action that called the function.
    ///
    /// - TODO: make private
    func setHeaderImage(_ alert: UIAlertAction) {
        saveEditsDelegate?.setProfileAs(imageAt: currentIndex)
    }
    
    /// Delete the current image. This requires the image be deleted from this collection view, the parent collection view, the `Plant` object's image array
    /// and from disk. All but the first of these tasks are completed by delegates.
    /// - parameter alert: The alert action that called the function.
    ///
    /// - TODO: make private
    func deleteImageTapped(_ alert: UIAlertAction) {
        let alertController = UIAlertController(title: "Delete image?", message: "Are you sure you want to delete the image from your library?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            if let delegate = self?.saveEditsDelegate,
                let index = self?.currentIndex {
                delegate.deleteImage(at: index)
            }
            
            let indexToDelete = self!.currentIndex
            
            self?.containerDelegate?.removeCell(at: indexToDelete)
            self?.images.remove(at: indexToDelete)
            self?.collectionView.deleteItems(at: [IndexPath(item: indexToDelete, section: 0)])
            
            if indexToDelete == (self?.images.count)! {
                self?.currentIndex = self!.currentIndex - 1
            } else {
                self?.currentIndex = self!.currentIndex
            }
            self?.containerDelegate?.containerViewController(self!, indexDidChangeTo: self!.currentIndex)
            
            if self!.images.count == 0 {
                self?.navigationController?.popViewController(animated: false)
            }
        })
        present(alertController, animated: true)
    }
}



// MARK: CropViewControllerDelegate

extension ImagePagingCollectionViewController: CropViewControllerDelegate {
    
    // cropping was canceled
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true)
    }
    
    // cropping was saved
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        images[currentIndex] = image
        if let delegate = saveEditsDelegate {
            delegate.save(image: image, withIndex: currentIndex)
        }
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
}
