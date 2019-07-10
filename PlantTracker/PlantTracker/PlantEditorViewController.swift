//
//  PlantEditorViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/9/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantEditorViewController: UIViewController {
    var plant: Plant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testLabel = UILabel()
        testLabel.text = "test label"
        testLabel.backgroundColor = .blue
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        testLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        testLabel.sizeToFit()
    }
}
