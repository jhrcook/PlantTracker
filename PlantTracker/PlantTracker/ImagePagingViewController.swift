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
    
    // hide the status bar when the navigation controller hides, too
    override var prefersStatusBarHidden: Bool {
        return navigationController!.isNavigationBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupMainScrollView()
        
        // tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        view.addGestureRecognizer(tap)
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
    
    @objc func handleGesture() {
        let animationDuration = 0.2
        if mainScrollView.backgroundColor == .white {
            UIView.animate(withDuration: animationDuration) { self.mainScrollView.backgroundColor = .black }
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            UIView.animate(withDuration: animationDuration) { self.mainScrollView.backgroundColor = .white }
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}


// scrolling
extension ImagePagingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll view offset - x: \(scrollView.contentOffset.x), y: \(scrollView.contentOffset.y)")
        updateTitleBy(scrollView.contentOffset)
    }
    
    // update title with which image is currently in view
    func updateTitleBy(_ contentOffset: CGPoint) {
        var imageNumber = Float((contentOffset.x - 0.5 * view.frame.width) / view.frame.width)
        print("imageNumber: \(imageNumber)")
        imageNumber.round(.up)
        title = "Image \(Int(imageNumber) + 1) of \(images.count)"
    }

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
            let imageView = UIImageView()
            imageView.frame = CGRect(x: viewWidth * CGFloat(i), y: 0, width: viewWidth, height: viewHeight)
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            mainScrollView.addSubview(imageView)
        }
        
        // set starting point at the image that was tapped
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.setContentOffset(CGPoint(x: viewWidth * CGFloat(startingIndex), y: 0), animated: false)
    }
}
