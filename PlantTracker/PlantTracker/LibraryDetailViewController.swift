//
//  LibraryDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit

class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var startingYOffset: CGFloat? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if startingYOffset == nil { startingYOffset = scrollView.contentOffset.y }
        updateHeaderImage(offset: scrollView.contentOffset)
    }
    
    func updateHeaderImage(offset: CGPoint) {
        let scrollViewYDiff = startingYOffset! - offset.y
        
        headerView.frame = CGRect(x: 0, y: offset.y, width: headerView.frame.width, height: headerView.frame.height)
        
        if scrollViewYDiff == 0 {
            return
        } else if scrollViewYDiff > 0 {
            // scrolling up
            
            // zoom in at most 1.3x
            let scaleFactor = min(scrollViewYDiff / 200.0 + 1.0, 1.3)
            headerImageView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            print("SCROLLING UP: scroll view difference: \(scrollViewYDiff) -- scale factor: \(scaleFactor)")
        } else  if scrollViewYDiff < 0 {
            // scrolling down
        }
    }

    
    func setupDetailView() {
        
        // main scroll view
        mainScrollView.delegate = self
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: 3000.0)
        mainScrollView.backgroundColor = .green
        mainScrollView.snp.makeConstraints { (make) in make.edges.equalTo(view) }
        
        // header view
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(mainScrollView.snp.top).priority(.medium)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(400)
        }
        
        // header image
        headerImageView.image = UIImage(named: "cactus")
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.snp.makeConstraints { (make) in make.edges.equalTo(headerView) }
        
        // segmented control setup
        
    }
    
}
