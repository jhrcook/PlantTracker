//
//  PlantEditorViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/9/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

struct labelAndSegmentedControllerPair {
    let label: UILabel
    let segmentedControl: UISegmentedControl
}

class PlantEditorViewController: UIViewController, UITextFieldDelegate {
    var plant: Plant!
    
    var scientificNameTextField = UITextField()
    var commonNameTextField = UITextField()
    var lightLevelLabel = UILabel()
    var lightSegmentedControl = UISegmentedControl()
    var difficultyLevelLabel = UILabel()
    var difficultySegmentedControl = UISegmentedControl()
    var wateringLevelLabel = UILabel()
    var wateringLevelSegmentedControl = UISegmentedControl()
    var growingSeasonLabel = UILabel()
    var growingSeasonSegementedControl = UISegmentedControl()
    var dormantSeasonLabel = UILabel()
    var dormantSeasonSegmentedControl = UISegmentedControl()
    
    let textHeight: CGFloat = 30.0
    let standardSpacing: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = plant.scientificName == nil ? "Edit plant" : "Editing \(plant.scientificName!)"
        
        // scientific name editing text field
        if let scientificName = plant.scientificName {
            scientificNameTextField.text = scientificName
        } else {
            scientificNameTextField.placeholder = "scientific name"
        }
        scientificNameTextField.font = UIFont.italicSystemFont(ofSize: scientificNameTextField.font?.pointSize ?? UIFont.systemFontSize)
        scientificNameTextField.delegate = self
        scientificNameTextField.clearButtonMode = .whileEditing
        scientificNameTextField.autocorrectionType = .no
        scientificNameTextField.returnKeyType = .done
        view.addSubview(scientificNameTextField)
        scientificNameTextField.translatesAutoresizingMaskIntoConstraints = false
        scientificNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0).isActive = true
        scientificNameTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        scientificNameTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        scientificNameTextField.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        scientificNameTextField.sizeToFit()
        
        if let commonName = plant.commonName {
            commonNameTextField.text = commonName
        } else {
            commonNameTextField.placeholder = "common name"
        }
        commonNameTextField.delegate = self
        commonNameTextField.clearButtonMode = .whileEditing
        commonNameTextField.autocorrectionType = .no
        commonNameTextField.returnKeyType = .done
        view.addSubview(commonNameTextField)
        commonNameTextField.translatesAutoresizingMaskIntoConstraints = false
        commonNameTextField.topAnchor.constraint(equalTo: scientificNameTextField.bottomAnchor, constant: standardSpacing).isActive = true
        commonNameTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        commonNameTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        commonNameTextField.sizeToFit()
        
        let thinLineLabel = UILabel()
        thinLineLabel.backgroundColor = .gray
        view.addSubview(thinLineLabel)
        thinLineLabel.translatesAutoresizingMaskIntoConstraints = false
        thinLineLabel.topAnchor.constraint(equalTo: commonNameTextField.bottomAnchor, constant: standardSpacing).isActive = true
        thinLineLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        thinLineLabel.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        thinLineLabel.sizeToFit()
        
        
        
        // lighting level segmented controller
        lightLevelLabel.text = "Light intesity"
        for (index, level) in LightingLevel.allCases.enumerated() {
            lightSegmentedControl.insertSegment(withTitle: level.rawValue, at: index, animated: true)
            if plant.lightRequirements == level {
                lightSegmentedControl.selectedSegmentIndex = index
            }
        }
        lightSegmentedControl.addTarget(self, action: #selector(updateLighting), for: UIControl.Event.valueChanged)
        
        // difficulty segmented controller
        difficultyLevelLabel.text = "Difficulty"
        for level in DifficultyLevel.allCases {
            difficultySegmentedControl.insertSegment(withTitle: String(repeating: "!", count: level.rawValue), at: level.rawValue - 1, animated: true)
            if plant.difficultyLevel == level  {
                difficultySegmentedControl.selectedSegmentIndex = level.rawValue - 1
            }
        }
        difficultySegmentedControl.addTarget(self, action: #selector(updateDifficulty), for: UIControl.Event.valueChanged)

        // watering level segmented controller
        wateringLevelLabel.text = "Watering"
        for (index, level) in WateringLevel.allCases.enumerated() {
            wateringLevelSegmentedControl.insertSegment(withTitle: level.rawValue, at: index, animated: true)
            if plant.wateringRequirements == level {
                wateringLevelSegmentedControl.selectedSegmentIndex = index
            }
        }
        wateringLevelSegmentedControl.addTarget(self, action: #selector(updateWatering), for: UIControl.Event.valueChanged)
        
        growingSeasonLabel.text = "Growing season"
        for (index, level) in Season.allCases.enumerated() {
            growingSeasonSegementedControl.insertSegment(withTitle: level.rawValue, at: index, animated: true)
            if plant.growingSeason == level {
                growingSeasonSegementedControl.selectedSegmentIndex = index
            }
        }
        growingSeasonSegementedControl.addTarget(self, action: #selector(updateGrowingSeason), for: UIControl.Event.valueChanged)

        
        let labelsAndSegementedControllers = [
            labelAndSegmentedControllerPair(label: lightLevelLabel, segmentedControl: lightSegmentedControl),
            labelAndSegmentedControllerPair(label: difficultyLevelLabel, segmentedControl: difficultySegmentedControl),
            labelAndSegmentedControllerPair(label: wateringLevelLabel, segmentedControl: wateringLevelSegmentedControl),
            labelAndSegmentedControllerPair(label: growingSeasonLabel, segmentedControl: growingSeasonSegementedControl),
        ]
        
        var previousBottomAnchor = thinLineLabel.bottomAnchor
        for labelAndSegmentedController in labelsAndSegementedControllers {
            let label = labelAndSegmentedController.label
            let segmentControl = labelAndSegmentedController.segmentedControl
            
            view.addSubview(label)
            view.addSubview(segmentControl)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: previousBottomAnchor, constant: standardSpacing).isActive = true
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: 0.5 * view.frame.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
            
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            if segmentControl == growingSeasonSegementedControl {
                segmentControl.topAnchor.constraint(equalTo: label.bottomAnchor, constant: standardSpacing).isActive = true
                segmentControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
                segmentControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
                segmentControl.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
                previousBottomAnchor = segmentControl.bottomAnchor
            } else {
                segmentControl.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
                segmentControl.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
                segmentControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
                segmentControl.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
                previousBottomAnchor = label.bottomAnchor
            }
        }
    }
    
    @objc func updateLighting() {
        for lightLevel in LightingLevel.allCases {
            if lightSegmentedControl.titleForSegment(at: lightSegmentedControl.selectedSegmentIndex) == lightLevel.rawValue {
                plant.lightRequirements = lightLevel
            }
        }
    }
    @objc func updateDifficulty() {
        for difficultyLevel in DifficultyLevel.allCases {
            if difficultySegmentedControl.selectedSegmentIndex + 1 == difficultyLevel.rawValue {
                plant.difficultyLevel = difficultyLevel
            }
        }
    }
    @objc func updateWatering() {
        for waterLevel in WateringLevel.allCases {
            if wateringLevelSegmentedControl.titleForSegment(at: wateringLevelSegmentedControl.selectedSegmentIndex) == waterLevel.rawValue {
                plant.wateringRequirements = waterLevel
            }
        }
    }
    @objc func updateGrowingSeason() {
        for season in Season.allCases {
            if growingSeasonSegementedControl.titleForSegment(at: growingSeasonSegementedControl.selectedSegmentIndex) == season.rawValue {
                plant.growingSeason = season
            }
        }
    }
    
    func updateScientificName() {
        plant.scientificName = scientificNameTextField.text
    }
    func updateCommonName() {
        plant.commonName = commonNameTextField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateScientificName()
        updateCommonName()
        textField.resignFirstResponder()
        return true
    }
}
