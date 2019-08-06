//
//  ImagePagingCollectionViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/5/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "scrollingImageCell"

class ImagePagingCollectionViewController: UICollectionViewController {

    var startingIndex: Int = 0
    var images = [UIImage]()
    
    var currentIndex: Int = 0 {
        didSet {
            self.title = "Image \(Int(currentIndex) + 1) of \(images.count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(ImagePagingViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        setupCollectionView()
        
        // swipe to dismiss
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        downSwipe.direction = .down
        collectionView.addGestureRecognizer(downSwipe)
    }
    
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        print("swipe")
        if gestureRecognizer.state == .ended && gestureRecognizer.direction == .down {
            dismiss(animated: true)
        }
    }
    
    
    func setupCollectionView() {
        
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = true
        
        collectionView.contentSize = CGSize(width: view.frame.width * CGFloat(images.count), height: 0.0)
        
        // collectionView.delegate = self
        collectionView.dataSource = self
        
        // set initial index at `startingIndex`
        collectionView.scrollToItem(at: IndexPath(item: startingIndex, section: 0), at: .right, animated: false)
        currentIndex = startingIndex
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
    
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("paging collection vertical view scrolling: y = \(scrollView.contentOffset.y)")
        if (abs(scrollView.contentOffset.y) > 100.0) { dismiss(animated: true) }
        
        var imageNumber = Float((scrollView.contentOffset.x - 0.5 * view.frame.width) / view.frame.width)
        imageNumber.round(.up)
        currentIndex = Int(imageNumber)
        print("current index: \(imageNumber)")
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
