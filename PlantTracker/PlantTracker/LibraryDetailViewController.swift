//
//  LibraryDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit

class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var plant: Plant!
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var informationView: UIView!
    
    var generalInfoTableView: UITableView!
    var notesTextView = UITextField()
    var linksTableView: UITableView!
    
    var startingYOffset: CGFloat? = nil
    
    // height of header image
    let headerImageHeight = 350
    let minHeaderImageHeight = 100
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInformationTableViews()
        setupDetailView()
        updateInformationView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView && startingYOffset == nil {
            // initialize starting Y offset
            startingYOffset = scrollView.contentOffset.y
        }
        
        if scrollView == mainScrollView {
            updateHeaderImage(offset: scrollView.contentOffset)
        }
    }
    
    func updateHeaderImage(offset: CGPoint) {
        let scrollViewYDiff = startingYOffset! - offset.y
        
        // sticky header
        let newHeight = max(CGFloat(headerImageHeight) + scrollViewYDiff, CGFloat(minHeaderImageHeight))
        headerView.snp.remakeConstraints { (make) in
            make.top.equalTo(view).offset(abs(startingYOffset!))
            make.height.equalTo(newHeight)
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
        }
        
        if scrollViewYDiff >= 0 {
            // scrolling up
//            print("SCROLLING UP: scroll view difference: \(scrollViewYDiff)")
            blurEffectView.alpha = 0.0
        } else  if scrollViewYDiff < 0 {
            // scrolling down
//            print("SCROLLING DOWN: scroll view difference: \(scrollViewYDiff)")
            
            let frameHeight = CGFloat(headerView.frame.height)
            let maxHeight = CGFloat(headerImageHeight)
            let minHeight = CGFloat(minHeaderImageHeight)
            let blurAlpha = (frameHeight - maxHeight) / (maxHeight - minHeight) * (0.0 - 0.85) + 0.0
            blurEffectView.alpha = blurAlpha
            
        }
    }
    
    
    @objc func updateSegmentedControl() {
        print("segment selection index: \(segmentedControl.selectedSegmentIndex)")
        updateInformationView()
    }
    
    
    func updateInformationView() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // "Information"
            generalInfoTableView.isHidden = false
            notesTextView.isHidden = true
            linksTableView.isHidden = true
        case 1:
            // "Notes"
            generalInfoTableView.isHidden = true
            notesTextView.isHidden = false
            linksTableView.isHidden = true
        case 2:
            // "Links"
            generalInfoTableView.isHidden = true
            notesTextView.isHidden = true
            linksTableView.isHidden = false
        default:
            break
        }
    }

    
    func setupDetailView() {
        
        // main scroll view
        mainScrollView.delegate = self
        mainScrollView.snp.makeConstraints { (make) in make.edges.equalTo(view) }
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        
        // header view
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(mainScrollView)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(headerImageHeight)
        }
        
        // header image
        if let imageName = plant.bestSingleImage() {
            headerImageView.image = UIImage(contentsOfFile: imageName)
        } else {
            headerImageView.image = UIImage(named: "cactus")
        }
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
        
        // segmented control setup
        segmentedControl.setTitle("Information", forSegmentAt: 0)
        segmentedControl.setTitle("Notes", forSegmentAt: 1)
        segmentedControl.setTitle("Links", forSegmentAt: 2)
        segmentedControl.setEnabled(true, forSegmentAt: 0)
        segmentedControl.addTarget(self, action: #selector(updateSegmentedControl), for: .valueChanged)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(35)
            
        }
        
        // information view (below segmented control)
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        // information subviews
        informationView.addSubview(generalInfoTableView)
        informationView.addSubview(notesTextView)
        informationView.addSubview(linksTableView)
        generalInfoTableView.snp.makeConstraints { (make) in make.edges.equalTo(informationView)}
        notesTextView.snp.makeConstraints { (make) in make.edges.equalTo(informationView) }
        linksTableView.snp.makeConstraints { (make) in make.edges.equalTo(informationView) }
        
        // set up notes text view
        notesTextView.placeholder = "Notes"
        notesTextView.contentVerticalAlignment = .top
        
        // initalize content height of main scroll view
        let contentHeight = CGFloat(headerImageHeight) + view.frame.height - CGFloat(minHeaderImageHeight)
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: contentHeight)
    }
}



extension LibraryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupInformationTableViews() {
        generalInfoTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        generalInfoTableView.delegate = self
        generalInfoTableView.dataSource = self
        generalInfoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "generalInfoCell")
        
        linksTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        linksTableView.delegate = self
        linksTableView.dataSource = self
        linksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "linksCell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case generalInfoTableView:
            return 30
        case linksTableView:
            return 3
        default:
            fatalError("Unforeseen table view requesting number of cells")
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case generalInfoTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
            cell.textLabel?.text = "TEST GENERAL INFO - row \(indexPath.row)"
            return cell
        case linksTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath)
            cell.textLabel?.text = "TEST LINKS - row\(indexPath.row)"
            return cell
        default:
            fatalError("Unforeseen table view requesting a `UITableViewCell`")
        }
    }
}
