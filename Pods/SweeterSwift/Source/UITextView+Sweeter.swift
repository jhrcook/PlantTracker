//
//  UITextView+Sweeter.swift
//
//  Created by Yonat Sharon on 2019-02-08.
//

import UIKit

extension UITextView {
    /// SweeterSwift: Create a label with links, by using a `UITextView` to auto-detect links and simulate `UILabel` appearance.
    public convenience init(simulatedLabelWithLinksInText: String, font: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)) {
        self.init()
        text = simulatedLabelWithLinksInText
        isEditable = false
        dataDetectorTypes = .link
        textAlignment = .center
        textContainerInset = .zero
        backgroundColor = .clear
        self.font = font
        constrain(.height, to: font.pointSize * 1.5)
    }
}
