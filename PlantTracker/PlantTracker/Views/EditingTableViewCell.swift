//
//  EditingTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 9/9/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit

class EditingTableViewCell: UITableViewCell {
    
    var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension EditingTableViewCell {
    func setupSegmentedController(withValues values: [String]) {
        segmentedControl = UISegmentedControl(items: values)
        setUpSegmentedView()
    }
    
    
    func setUpSegmentedView() {
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }
}
