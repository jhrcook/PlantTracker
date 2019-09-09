//
//  EditingTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 9/9/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit
import MultiSelectSegmentedControl

class EditingTableViewCell: UITableViewCell {
    
    var segmentedControl: MultiSelectSegmentedControl
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, items: [Any]?) {
        segmentedControl = MultiSelectSegmentedControl(items: items)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        segmentedControl.allowsMultipleSelection = true
        setUpSegmentedView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setUpSegmentedView() {
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        segmentedControl.borderRadius = 0
        segmentedControl.borderWidth = 0
        
        // segmentedControl.backgroundColor = UIColor(red: 247, green: 253, blue: 255)
        // segmentedControl.tintColor = UIColor(red: 128, green: 217, blue: 255)
    }
}
