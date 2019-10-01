//
//  LibraryDetailView.swift
//  PlantTracker
//
//  Created by Joshua on 8/11/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit
import TwicketSegmentedControl
import KeyboardObserver
import Floaty

class LibraryDetailView: UIView {
    
    /// Main scroll view of the view.
    @IBOutlet var mainScrollView: UIScrollView!
    /// Header container view. It holds the `headerImageView`.
    @IBOutlet var headerView: UIView!
    /// The view with the image `headerImage`.
    @IBOutlet var headerImageView: UIImageView!
    /// The header image.
    var headerImage: UIImage? {
        didSet {
            if headerImageView != nil { headerImageView.image = headerImage }
        }
    }
    /// The segmented controller that controls which subview is visible.
    /// - Note: This custom segmented controller is from the package ['TwicketSegmentedControl'](https://github.com/twicketapp/TwicketSegmentedControl)
    var twicketSegementedControl: TwicketSegmentedControl!
    /// The subview with the views for the plant information.
    @IBOutlet var informationView: UIView!
    /// A button flowting within the header view, pinned to the top of the information view.
    /// It currently doesn't do anything.
    var floatyButton = Floaty()
    /// A table view with the general information about the plant.
    var generalInfoTableView: UITableView!
    /// A text view with the user's notes on the plants.
    var notesTextView: UITextView!
    /// A table view with links to external sources about the plant.
    var linksTableView: UITableView!
    
    /// A value to help adjust the scroll view set its content size.
    var startingYOffset: CGFloat? = nil
    
    /// Height of the navigation bar.
    /// - TODO: make private.
    var navigationBarHeight: CGFloat = 0.0
    /// The height of the header image. After scrolling beyond this height, the image zooms in.
    /// - TODO: make private.
    var headerImageHeight: CGFloat = 350.0
    /// Minimum height of the header image.
    /// - TODO: make private
    var minHeaderImageHeight: CGFloat = 100
    
    /// The blur effect for the header image.
    /// - TODO: make private
    var blurEffectView: UIVisualEffectView!
    
    /// Update the header image with an offset.
    /// - parameter offset: Amount to offset the image by (vertically only)
    func updateHeaderImage(offset: CGPoint) {
        let scrollViewYDiff = startingYOffset! - offset.y
        
        // sticky header
        let newHeight = max(headerImageHeight + scrollViewYDiff, minHeaderImageHeight)
        headerView.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(abs(startingYOffset!))
            make.height.equalTo(newHeight)
            make.trailing.equalTo(self)
            make.leading.equalTo(self)
        }
        
        if scrollViewYDiff >= 0 {
            // scrolling up
            blurEffectView.alpha = 0.0
        } else  if scrollViewYDiff < 0 {
            // scrolling down
            let frameHeight = headerView.frame.height
            let maxHeight = headerImageHeight
            let minHeight = minHeaderImageHeight
            let blurAlpha = (frameHeight - maxHeight) / (maxHeight - minHeight) * (0.0 - 0.85) + 0.0
            blurEffectView.alpha = blurAlpha
        }
    }

}



// MARK: Set Up

extension LibraryDetailView {
    
    /// Set up the views.
    /// - TODO: make private and run during init
    func setupView() {
        headerImageHeight += navigationBarHeight
        minHeaderImageHeight += navigationBarHeight
        setupConstraints()
    }
    
    /// Set constraits for the subviews
    /// - TODO: make private
    func setupConstraints() {
        setupMainScrollView()
        setupHeaderView()
        setupHeaderImageView()
        setupTwicketSegmentedControl()
        setupFloatyButtonView()
        setUpFloatlyButton()
        setupInformationSubviews()
        
        // initalize content height of main scroll view
        let contentHeight = headerImageHeight + self.frame.height - minHeaderImageHeight + self.layoutMargins.top
        mainScrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
    }
    
    /// Set up the main scroll view.
    /// - TODO: make private
    func setupMainScrollView() {
        mainScrollView = UIScrollView()
        self.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in make.edges.equalTo(self) }
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
    }
    
    /// Set up the header view.
    /// - TODO: make private
    func setupHeaderView() {
        headerView = UIView()
        mainScrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(mainScrollView)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(headerImageHeight)
        }
    }
    
    /// Set up the header image view.
    /// - TODO: make private
    func setupHeaderImageView() {
        
        headerImageView = UIImageView()
        headerView.addSubview(headerImageView)
        
        headerImageView.image = headerImage
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.snp.makeConstraints { (make) in make.edges.equalTo(headerView) }
        
        // blur effect on header
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.alpha = 0.0
        headerView.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(headerView)
        }
    }
    
    /// Set up the segmented control that decides which information subview is visible.
    /// - TODO: make private
    func setupTwicketSegmentedControl() {
        twicketSegementedControl = TwicketSegmentedControl(frame: CGRect(x: 5, y: 0, width: self.frame.height - 10, height: 40))
        twicketSegementedControl.setSegmentItems(["Information", "Notes", "Links"])
        self.addSubview(twicketSegementedControl)
        twicketSegementedControl.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(35)
        }
    }
    
    /// Set up the view of the floating button.
    /// - TODO: make private
    func setupFloatyButtonView() {
        let padding = 20
        floatyButton.paddingX = CGFloat(padding)
        floatyButton.paddingY = CGFloat(padding)
        let floatlyFrame = floatyButton.frame
        headerView.addSubview(floatyButton)
        floatyButton.snp.makeConstraints { make in
            make.bottom.equalTo(headerView.snp.bottom).inset(padding)
            make.right.equalTo(headerView.snp.right).inset(padding)
            make.width.equalTo(floatlyFrame.width)
            make.height.equalTo(floatlyFrame.height)
        }
    }
    
    /// Set up the floating button.
    /// - TODO: make private
    func setUpFloatlyButton() {
        // stlying
        floatyButton.relativeToSafeArea = false
        floatyButton.sticky = true
        floatyButton.hasShadow = true
        floatyButton.buttonShadowColor = .darkGray
        floatyButton.buttonColor = .gray
        
        floatyButton.autoCloseOnTap = true
        floatyButton.isUserInteractionEnabled = true
        floatyButton.isHidden = false
        floatyButton.openAnimationType = .slideUp
        floatyButton.animationSpeed = 1.0
        
        // item 1: add photos
        let addPhotosItem = FloatyItem()
        addPhotosItem.title = "Add photos"
        addPhotosItem.icon = UIImage(named: "cameraIconBW")
        addPhotosItem.titleColor = .white
        addPhotosItem.buttonColor = .lightGray
        //        addPhotosItem.handler = addImages()
        floatyButton.addItem(item: addPhotosItem)
        
        // item 2: view all photos
        let viewPhotosItem = FloatyItem()
        viewPhotosItem.title = "View photos"
        viewPhotosItem.titleColor = .white
        viewPhotosItem.buttonColor = .lightGray
        viewPhotosItem.icon = UIImage(named: "albumIconBW")
        floatyButton.addItem(item: viewPhotosItem)
    }
    
    /// Set up the information subviews (general information, notes, and sources table).
    /// - TODO: make private
    func setupInformationSubviews() {
        
        // information view (below segmented control)
        informationView = UIView()
        self.addSubview(informationView)
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(twicketSegementedControl.snp.bottom).offset(5)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        generalInfoTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        generalInfoTableView.register(GeneralInformtationTableViewCell.self, forCellReuseIdentifier: "generalInfoCell")
        notesTextView = UITextView()
        linksTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        linksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "linksCell")
        informationView.addSubview(generalInfoTableView)
        informationView.addSubview(notesTextView)
        informationView.addSubview(linksTableView)
        generalInfoTableView.snp.makeConstraints { (make) in make.edges.equalTo(informationView)}
        notesTextView.snp.makeConstraints { (make) in make.edges.equalTo(informationView).offset(8) }
        linksTableView.snp.makeConstraints { (make) in make.edges.equalTo(informationView) }
        
        // set up notes text view
        notesTextView.textAlignment = .left
        notesTextView.returnKeyType = .default
        notesTextView.font = UIFont.systemFont(ofSize: 17)
    }
}
