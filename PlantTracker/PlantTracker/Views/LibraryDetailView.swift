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
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    var headerImage: UIImage? {
        didSet {
            if headerImageView != nil { headerImageView.image = headerImage }
        }
    }
    var twicketSegementedControl: TwicketSegmentedControl!
    @IBOutlet var informationView: UIView!
    var floatyButton = Floaty()
    var generalInfoTableView: UITableView!
    var notesTextView: UITextView!
    var linksTableView: UITableView!
    
    var startingYOffset: CGFloat? = nil
    
    var notesText: String = ""
    
    var navigationBarHeight: CGFloat = 0.0
    var headerImageHeight: CGFloat = 350.0
    var minHeaderImageHeight: CGFloat = 100
    
    var blurEffectView: UIVisualEffectView!
    
    
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
    
    func setupView() {
        headerImageHeight += navigationBarHeight
        minHeaderImageHeight += navigationBarHeight
        setupConstraints()
    }
    
    
    func setupConstraints() {
        setupMainScrollView()
        setupHeaderView()
        setupHeaderImageView()
        setupTwicketSegmentedControl()
        setupFloatyButtonView()
        setUpFloatlyButton()
        setupInformationSubviews()
        
        // initalize content height of main scroll view
        let contentHeight = headerImageHeight + self.frame.height - minHeaderImageHeight
        mainScrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
    }
    
    func setupMainScrollView() {
        mainScrollView = UIScrollView()
        self.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in make.edges.equalTo(self) }
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
    }
    
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
        generalInfoTableView.allowsSelection = false
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
        if notesText.count > 0 {
            notesTextView.text = notesText
            notesTextView.textColor = .black
        } else {
            notesTextView.text = "Notes"
            notesTextView.textColor = .lightGray
        }
    }
}
