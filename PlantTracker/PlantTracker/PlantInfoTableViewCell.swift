//
//  PlantInfoTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 7/26/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit

class PlantInfoTableViewCell: UITableViewCell {
    
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .blue
        setupCellView()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCellView() {
        leftLabel.textAlignment = .left
        leftLabel.backgroundColor = .green
        leftLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        leftLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView.snp.leading).offset(15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(44)
        }
        
        rightLabel.textAlignment = .right
        rightLabel.backgroundColor = .red
        rightLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(leftLabel.snp.trailing)
            make.trailing.equalTo(contentView.snp.trailing).offset(15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(leftLabel.snp.height)
        }
    }

}
