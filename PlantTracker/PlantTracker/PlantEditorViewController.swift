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
    
    var lightSegmentedControl = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, level) in LightingLevel.allCases.enumerated() {
            lightSegmentedControl.insertSegment(withTitle: level.rawValue, at: index, animated: true)
        }
        lightSegmentedControl.selectedSegmentIndex = 0
        view.addSubview(lightSegmentedControl)
        lightSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        lightSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        lightSegmentedControl.sizeToFit()
        lightSegmentedControl.addTarget(self, action: #selector(updateValue), for: UIControl.Event.valueChanged)
    }
    
    @objc func updateValue() {
        for lightLevel in LightingLevel.allCases {
            if lightSegmentedControl.titleForSegment(at: lightSegmentedControl.selectedSegmentIndex) == lightLevel.rawValue {
                print("setting new light level: \(lightLevel.rawValue)")
                plant.lightRequirements = lightLevel
            }
        }
    }
}
