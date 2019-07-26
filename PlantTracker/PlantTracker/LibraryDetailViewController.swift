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
    
    // height of header image
    let headerImageHeight = 350
    let minHeaderImageHeight = 100
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // initialize starting Y offset
        if startingYOffset == nil { startingYOffset = scrollView.contentOffset.y }
        
        // update header
        updateHeaderImage(offset: scrollView.contentOffset)
    }
    
    func updateHeaderImage(offset: CGPoint) {
        let scrollViewYDiff = startingYOffset! - offset.y
        
        // sticky header
        let newHeight = max(CGFloat(headerImageHeight) + scrollViewYDiff, CGFloat(minHeaderImageHeight))
        headerView.snp.remakeConstraints { (make) in
            make.top.equalTo(view).offset(abs(startingYOffset!))
            make.height.equalTo(newHeight)
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
        }
        
        if scrollViewYDiff == 0 {
            return
        } else if scrollViewYDiff > 0 {
            // scrolling up
            print("SCROLLING UP: scroll view difference: \(scrollViewYDiff)")
            
            
            
        } else  if scrollViewYDiff < 0 {
            // scrolling down
            print("SCROLLING DOWN: scroll view difference: \(scrollViewYDiff)")
            
            let frameHeight = CGFloat(headerView.frame.height)
            let maxHeight = CGFloat(headerImageHeight)
            let minHeight = CGFloat(minHeaderImageHeight)
            let blurAlpha = (frameHeight - maxHeight) / (maxHeight - minHeight) * (0.0 - 0.7) + 0.0
            print("blur alpha: \(blurAlpha)")
            blurEffectView.alpha = blurAlpha
            
        }
    }

    
    func setupDetailView() {
        
        // main scroll view
        mainScrollView.delegate = self
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: 3000.0)
        mainScrollView.backgroundColor = .green
        mainScrollView.snp.makeConstraints { (make) in make.edges.equalTo(view) }
        
        // header view
        headerView.layer.borderColor = UIColor.orange.cgColor
        headerView.layer.borderWidth = 3.0
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(mainScrollView)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(headerImageHeight)
        }
        
        // header image
        headerImageView.layer.borderColor = UIColor.purple.cgColor
        headerImageView.layer.borderWidth = 3.0
        headerImageView.image = UIImage(named: "cactus")
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.snp.makeConstraints { (make) in make.edges.equalTo(headerView) }
        
        // segmented control setup
        segmentedControl.setTitle("Information", forSegmentAt: 0)
        segmentedControl.setTitle("Notes", forSegmentAt: 1)
        segmentedControl.setTitle("Links", forSegmentAt: 2)
        segmentedControl.setEnabled(true, forSegmentAt: 0)
        segmentedControl.addTarget(self, action: #selector(updateSegmentedControl), for: .valueChanged)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
//            make.height.equalTo(UIBarMetrics.default)
        }
        
        // blur effect on header
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.alpha = 0.0
        headerView.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(headerView)
        }
        
    }
    
    @objc func updateSegmentedControl() {
        print("segment selection index: \(segmentedControl.selectedSegmentIndex)")
    }
    
}
