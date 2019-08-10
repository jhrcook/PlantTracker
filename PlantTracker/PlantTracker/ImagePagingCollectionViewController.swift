//
//  ImagePagingCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/5/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "scrollingImageCell"

protocol ImagePagingCollectionViewControllerDelegate {
    func containerViewController(_ containerViewController: ImagePagingCollectionViewController, indexDidChangeTo currentIndex: Int)
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
    }
    
    
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

    // MARK: UICollectionViewDataSource

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
    
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var imageNumber = Float((scrollView.contentOffset.x - 0.5 * view.frame.width) / view.frame.width)
        imageNumber.round(.up)
        currentIndex = Int(imageNumber)
    }
    
    // change the base view controller's index, too
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        containerDelegate?.containerViewController(self, indexDidChangeTo: currentIndex)
    }
}



// sizing of collection view cells
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


extension ImagePagingCollectionViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        // add code here to be run just before the transition animation
        hideCellImageViews = zoomAnimator.isPresenting
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        // add code here to be run just after the transition animation
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


// handle pan gesture
extension ImagePagingCollectionViewController {
    
    @objc func userDidPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            transitionController.isInteractive = true
            let _ = navigationController?.popViewController(animated: true)
        case .ended:
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
