//
//  ImagePagingViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 8/4/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit

/// A protocol for the communication of taping on the cell to the parent view controller.
protocol PagingViewWasTappedDelegate: class {
    func pagingViewCell(_ pagingViewCell: ImagePagingViewCell, shouldBeTurnedBlack: Bool)
}


/**
 A custom cell for the `ImagePagingCollectionViewController`.
 It present an image in full screen and the background turns black/white when the image is tapped. The user can
 pinch or double-tap to zoom and then pan around within the zoomed-in view.
 
 - TODO: for dark mode, always keep the background black - just hide the nav bar
 */
class ImagePagingViewCell: UICollectionViewCell {
    
    /// The image to display full screen.
    var image: UIImage? {
        didSet {
            configureForNewImage(animated: false)
        }
    }
    
    /// The view controller that gets notified if the cell is tapped.
    weak var delegate: PagingViewWasTappedDelegate?
    
    /// The scroll view for zooming and panning.
    @IBOutlet var scrollView: UIScrollView!
    /// The image view that holds the image.
    @IBOutlet var imageView: UIImageView!
    
    /// The factor by which the view zooms in when double-tapped.
    var zoomFactor: CGFloat = 3.0
    
    /// A `Boolean` to track if the view cell has been turned black (or not)
    /// - TODO: rename to not confuse with iOS 13 Dark Mode
    var isInBlackMode = false {
        didSet{
            delegate?.pagingViewCell(self, shouldBeTurnedBlack: isInBlackMode)
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // content view
        contentView.backgroundColor = .clear
        
        // scroll view
        scrollView = UIScrollView()
        scrollView.frame = frame
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in make.edges.equalTo(contentView) }
        
        // image view
        imageView = UIImageView()
        imageView.image = image
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in make.edges.equalTo(scrollView) }
        
        scrollView.contentSize = imageView.frame.size
        
        // double tap to zoom
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        
    }
    
    // inserted by compiler/autocomplete
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configure the cell for a new image.
    /// - TODO: rename this `configureFor(image:animated:)` instead of having the VC edit the image and it being called indirectly
    /// Just a change in API, not actual function or style.
    func configureForNewImage(animated: Bool = true) {
        imageView.image = image
        imageView.sizeToFit()
        
        setZoomScale()
        scrollViewDidZoom(scrollView)
        
        if animated {
            imageView.alpha = 0.0
            UIView.animate(withDuration: 0.5) { self.imageView.alpha = 1.0}
        }
    }
}


// MARK: tap gestures

extension ImagePagingViewCell {
    
    /// Called when a user double-taps on an image to zoom in or out.
    /// - parameter gestureRecognizer: The gesture that called the function. 
    /// - TODO: make private
    @objc func doubleTapAction(_ gestureRecognizer: UIGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let tapLocation = gestureRecognizer.location(in: imageView)
            guard let imageSize = imageView.image?.size else { return }
            let zoomWidth = imageSize.width  / zoomFactor
            let zoomHeight = imageSize.height / zoomFactor
            scrollView.zoom(to: CGRect(center: tapLocation, size: CGSize(width: zoomWidth, height: zoomHeight)), animated: true)
        }
    }
    
    /// Called when a user single-taps on an image. Toggles the dark background and hiding of navigation bar.
    /// - parameter gestureRecognizer: The gesture that called the function.
    /// - TODO: make private
    @objc func singleTapAction(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            isInBlackMode.toggle()
        }
    }
}



extension ImagePagingViewCell: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// Calculates the minimum zoom scale of the scroll view based on the size of the image and view frame.
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
}

