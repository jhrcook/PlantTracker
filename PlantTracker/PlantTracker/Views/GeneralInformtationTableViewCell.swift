//
//  GeneralInformtationTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 7/28/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

/// Table view cells for the general information of a plant.
class GeneralInformtationTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        changeStyling()
    }
    
    // required: `fatalError` added by comiler recommendation
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Changes a bit of the styling from the standard iOS `UITableViewCell`.
    /// - TODO: make private
    func changeStyling() {
        textLabel?.font = UIFont.boldSystemFont(ofSize: textLabel?.font.pointSize ?? UIFont.systemFontSize)
        detailTextLabel?.textColor = .black
    }
}
