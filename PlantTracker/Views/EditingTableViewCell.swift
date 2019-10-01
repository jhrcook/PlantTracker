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

/// The custom cell for editing the information in the general information table view.
/// It contains a segmented controller that can have multiple selections.
class EditingTableViewCell: UITableViewCell {
    
    /// A multi-select segmented control.
    /// - Note: The `MultiSelectSegmentedControl` class if from the
    ///  ['MultiSelectSegmentedControl'](https://github.com/yonat/MultiSelectSegmentedControl) library
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
    
    /// Set up the segmented controller's view.
    fileprivate func setUpSegmentedView() {
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        segmentedControl.borderRadius = 0
        segmentedControl.borderWidth = 0
    }
}
