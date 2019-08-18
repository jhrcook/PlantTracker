//
//  PlantLibraryTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 8/10/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewCell: UITableViewCell {
    
    var iconImageView: UIImageView!
    var scientificNameLabel: UILabel!
    var commonNameLabel: UILabel!
    
    var scientificName: String? {
        didSet {
            setScientificLabel()
        }
    }
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
    
    func setupCell() {
        setupConstraints()
        setupCellView()
    }
    
    
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
    
    
    func setScientificLabel() {
        if let scientificName = scientificName {
            scientificNameLabel?.text = scientificName
        } else {
            scientificNameLabel?.text = "Unnamed"
            scientificNameLabel?.textColor = .gray
        }
        
        scientificNameLabel?.font = UIFont.italicSystemFont(ofSize: scientificNameLabel?.font.pointSize ?? UIFont.systemFontSize)
    }
    
    
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
