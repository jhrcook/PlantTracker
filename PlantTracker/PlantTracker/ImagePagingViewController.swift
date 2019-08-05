//
//  ImagePagingViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/3/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class ImagePagingViewController: UIViewController {

    var startingIndex: Int = 0
    var images = [UIImage]()
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    var currentIndex = 0
    var isZoomedIn = false
    
    // hide the status bar when the navigation controller hides, too
    // not in use if segue is modal
//    override var prefersStatusBarHidden: Bool {
//        return navigationController!.isNavigationBarHidden
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        currentIndex = startingIndex
        updateTitleBy(CGPoint(x: 0, y: 0))
        setupMainScrollView()
        
        // tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//        doubleTap.numberOfTapsRequired = 2
//        view.addGestureRecognizer(doubleTap)
//        tap.require(toFail: doubleTap)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        print("tap")
        let animationDuration = 0.2
        if mainScrollView.backgroundColor == .white {
            UIView.animate(withDuration: animationDuration) { self.mainScrollView.backgroundColor = .black }
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            UIView.animate(withDuration: animationDuration) { self.mainScrollView.backgroundColor = .white }
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
//    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//        print("tap tap")
//        if isZoomedIn {
//            // zoom out
//
////            isZoomedIn = false
//        } else {
//            //zoom in
//            let tapLocation = gestureRecognizer.location(in: mainScrollView.subviews[currentIndex])
//            print("zooming in to \(tapLocation)")
//            let zoomRect = CGRect(center: tapLocation, size: CGSize(width: view.frame.width/1.5, height: view.frame.height/1.5))
//            print("zoom rect: \(zoomRect)")
//            mainScrollView.zoom(to: zoomRect, animated: true)
//            isZoomedIn = true
////            print("zoom scale: \(mainScrollView.zoomScale)")
//        }
//    }
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        print("swipe")
        if gestureRecognizer.state == .ended {
            if gestureRecognizer.direction == .down {
                performSegue(withIdentifier: "unwindToImageCollectionViewController", sender: self)
            }
        }
    }
}


// scrolling
extension ImagePagingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scroll view offset - x: \(scrollView.contentOffset.x), y: \(scrollView.contentOffset.y)")
        updateTitleBy(scrollView.contentOffset)
    }
    
    // update title with which image is currently in view
    func updateTitleBy(_ contentOffset: CGPoint) {
        var imageNumber = Float((contentOffset.x - 0.5 * view.frame.width) / view.frame.width)
        imageNumber.round(.up)
        currentIndex = Int(imageNumber)
        title = "Image \(Int(imageNumber) + 1) of \(images.count)"
    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return mainScrollView.subviews[currentIndex]
//    }
}


// set up inital view
extension ImagePagingViewController {
    func setupMainScrollView() {
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        mainScrollView.delegate = self
        mainScrollView.backgroundColor = .white
        mainScrollView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        mainScrollView.contentSize = CGSize(width: viewWidth * CGFloat(images.count), height: 0)
        mainScrollView.isPagingEnabled = true
        mainScrollView.scrollsToTop = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.alwaysBounceVertical = false
        mainScrollView.alwaysBounceHorizontal = true
        mainScrollView.isDirectionalLockEnabled = true
        
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        for i in 0..<images.count {
            // set up image view
            let imageView = UIImageView()
            imageView.frame = CGRect(x: viewWidth * CGFloat(i), y: 0, width: viewWidth, height: viewHeight)
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            
            // set up scroll view to put it in
            let imageScrollView = UIScrollView()
            imageScrollView.delegate = self
            imageScrollView.isScrollEnabled = true
            imageScrollView.contentSize = imageView.image?.size ?? view.frame.size
            
            // nest as follows: mainScrollView[ imageScrollView[ imageView ] ]
            imageScrollView.addSubview(imageView)
            imageView.snp.makeConstraints { make in make.edges.equalTo(imageScrollView) }
            mainScrollView.addSubview(imageScrollView)
        }
        
        // set starting point at the image that was tapped
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.setContentOffset(CGPoint(x: viewWidth * CGFloat(startingIndex), y: 0), animated: false)
    }
}
