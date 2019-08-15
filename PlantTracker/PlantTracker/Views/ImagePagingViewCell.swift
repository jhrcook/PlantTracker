//
//  ImagePagingViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 8/4/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit


protocol NavigationBarHidingAndShowingDelegate: class {
    func showNavigationBar()
    func hideNavigationBar()
}

class ImagePagingViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            configureForNewImage(animated: false)
        }
    }
    
    weak var navigationBarDelegate: NavigationBarHidingAndShowingDelegate?
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    // factor to zoom in by
    var zoomFactor: CGFloat = 3.0
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // content view
        contentView.backgroundColor = .white
        
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
    
    
    @objc func singleTapAction(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            if contentView.backgroundColor == .white {
                contentView.backgroundColor = .black
                navigationBarDelegate?.hideNavigationBar()
            } else {
                contentView.backgroundColor = .white
                navigationBarDelegate?.showNavigationBar()
            }
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
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
}

