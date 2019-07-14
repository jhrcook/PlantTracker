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
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var headerImageView: UIImageView!
    
    var headerHeight = CGFloat(50.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScrollView.delegate = self
        mainScrollView.contentSize.width = view.frame.width
        mainScrollView.contentSize.height = 2000
    
        testLabel.text = "Scroll view test"
        
        headerImageView = UIImageView(image: UIImage(named: "cactus"))
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        headerImageView.backgroundColor = .green
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        testLabel.text = "\(offset.x), \(offset.y)"
        
        
        
    }
    
}
