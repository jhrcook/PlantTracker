//
//  PlantLibraryTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 8/10/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

/**
 A custom cell for a plant in the library table view.
 
 - TODO: add a `configureCell(forPlant:)` function.
 */
class PlantLibraryTableViewCell: UITableViewCell {
    
    /// The image view for the icon.
    var iconImageView: UIImageView!
    /// The label for the scientific name.
    var scientificNameLabel: UILabel!
    /// The label for the common name.
    var commonNameLabel: UILabel!
    
    /// The scientific name of the plant.
    /// - TODO: remove from this view
    var scientificName: String? {
        didSet {
            setScientificLabel()
        }
    }
    
    /// The scientific name of the plant.
    /// - TODO: remove from this view
    var commonName: String? {
        didSet {
            commonNameLabel.text = commonName
            commonNameLabel.textColor = .darkGray
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}



// MARK: setup

extension PlantLibraryTableViewCell {
    
    /// Set up the cell subviews.
    /// - TODO: make private and run during init
    func setupCell() {
        setupConstraints()
        setupCellView()
    }
    
    /// Assign constraints to organize the subviews.
    /// - TODO: make private
    func setupConstraints() {
        iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView).inset(10)
            make.centerY.equalTo(contentView)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        scientificNameLabel = UILabel()
        contentView.addSubview(scientificNameLabel)
        scientificNameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.centerY.equalTo(contentView)
        }

        commonNameLabel = UILabel()
        contentView.addSubview(commonNameLabel)
        commonNameLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
    }
    
    /// Sets the scientific label depending on if the plant has one.
    func setScientificLabel() {
        if let scientificName = scientificName {
            scientificNameLabel?.text = scientificName
        } else {
            scientificNameLabel?.text = "Unnamed"
            scientificNameLabel?.textColor = .gray
        }
        
        scientificNameLabel?.font = UIFont.italicSystemFont(ofSize: scientificNameLabel?.font.pointSize ?? UIFont.systemFontSize)
    }
    
    /// Set up some smaller details of the cell.
    /// - TODO: make private and run during init
    func setupCellView() {
        
        // separator inset
        separatorInset.left = 65.0
        
        // arrow point to detail view controller
        accessoryType = .disclosureIndicator
        
        // cell image
        iconImageView?.layer.masksToBounds = true
        iconImageView?.layer.cornerRadius = 30
    }


}
