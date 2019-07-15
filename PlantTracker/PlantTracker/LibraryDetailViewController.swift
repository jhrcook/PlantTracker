//
//  LibraryDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    
    @IBOutlet var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.text = "test label"

        headerImageView.image = UIImage(named: "cactus")
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.clipsToBounds = true
        headerImageView.backgroundColor = .blue
        
    
        mainScrollView.delegate = self
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: 3000.0)
        mainScrollView.backgroundColor = .green
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView.contentOffset: \(scrollView.contentOffset)")
        testLabel.text = "x: \(scrollView.contentOffset.x), y: \(scrollView.contentOffset.y)"
        
    }
    
}
