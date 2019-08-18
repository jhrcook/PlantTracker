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

private let reuseIdentifier = "scrollingImageCell"


protocol ImagePagingCollectionViewControllerDelegate {
    func containerViewController(_ containerViewController: ImagePagingCollectionViewController, indexDidChangeTo currentIndex: Int)
    func removeCell(at index: Int)
}


protocol EditedImageDelegate {
    func save(image: UIImage, withIndex index: Int)
    func setProfileAs(imageAt index: Int)
    func deleteImage(at index: Int)
}


class ImagePagingCollectionViewController: UICollectionViewController {

    var startingIndex: Int = 0
    var images = [UIImage]()
    
    var currentIndex: Int = 0 {
        didSet {
            self.title = "Image \(Int(currentIndex) + 1) of \(images.count)"
        }
    }
    
    var hideCellImageViews = false
    var transitionController = ZoomTransitionController()
    var containerDelegate: ImagePagingCollectionViewControllerDelegate?
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
        cell.navigationBarDelegate = self
        
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
    
    @objc func userDidPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            os_log("Dismissing pan gesture began.", log: Log.pagingImageVC, type: .info)
            
            // unhide the navigation bar if needed and turn background white
            if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
                cell.contentView.backgroundColor = .white
                showNavigationBar()
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



// MARK: tap gesture

extension ImagePagingCollectionViewController {
    @objc func userDidTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if collectionView.backgroundColor == .white {
            collectionView.backgroundColor = .black
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            collectionView.backgroundColor = .white
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}



// MARK: NavigationBarHidingAndShowingDelegate

extension ImagePagingCollectionViewController: NavigationBarHidingAndShowingDelegate {
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}



// MARK: tappedRightBarButton

extension ImagePagingCollectionViewController {
    @objc func tappedActionButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Edit...", style: .default, handler: editPhoto))
        alertController.addAction(UIAlertAction(title: "Share...", style: .default, handler: shareImage))
        alertController.addAction(UIAlertAction(title: "Make header image", style: .default, handler: setHeaderImage))
        alertController.addAction(UIAlertAction(title: "Delete image", style: .destructive, handler: deleteImageTapped))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
    // edit photo
    func editPhoto(_ alert: UIAlertAction) {
        let image = images[currentIndex]
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    
    // share using UIActivityViewController
    func shareImage(_ alert: UIAlertAction) {
        let image = images[currentIndex]
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    
    func setHeaderImage(_ alert: UIAlertAction) {
        saveEditsDelegate?.setProfileAs(imageAt: currentIndex)
    }
    
    
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
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true)
    }
    
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        images[currentIndex] = image
        if let delegate = saveEditsDelegate {
            delegate.save(image: image, withIndex: currentIndex)
        }
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
}
