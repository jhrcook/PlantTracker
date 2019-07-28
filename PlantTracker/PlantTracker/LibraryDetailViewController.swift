//
//  LibraryDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import SnapKit
import TwicketSegmentedControl

class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var plant: Plant!
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    var twicketSegementedControl: TwicketSegmentedControl!
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
        
        title = plant.scientificName ?? plant.commonName ?? ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        
        setupInformationTableViews()
        setupDetailView()
        didSelect(0)
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
            blurEffectView.alpha = 0.0
        } else  if scrollViewYDiff < 0 {
            // scrolling down
            let frameHeight = CGFloat(headerView.frame.height)
            let maxHeight = CGFloat(headerImageHeight)
            let minHeight = CGFloat(minHeaderImageHeight)
            let blurAlpha = (frameHeight - maxHeight) / (maxHeight - minHeight) * (0.0 - 0.85) + 0.0
            blurEffectView.alpha = blurAlpha
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
        
        // twicket slider segmented control
        twicketSegementedControl = TwicketSegmentedControl(frame: CGRect(x: 5, y: 0, width: view.frame.height - 10, height: 40))
        twicketSegementedControl.setSegmentItems(["Information", "Notes", "Links"])
        twicketSegementedControl.delegate = self
        view.addSubview(twicketSegementedControl)
        twicketSegementedControl.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.height.equalTo(35)
        }
        
        // information view (below segmented control)
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(twicketSegementedControl.snp.bottom).offset(5)
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
        generalInfoTableView.register(GeneralInformtationTableViewCell.self, forCellReuseIdentifier: "generalInfoCell")
        
        linksTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        linksTableView.delegate = self
        linksTableView.dataSource = self
        linksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "linksCell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case generalInfoTableView:
            return 7
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
            var main: String?
            var detail: String?
            switch indexPath.row {
            case 0:
                main = "Scientific name"
                detail = plant.scientificName
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: cell.detailTextLabel?.font.pointSize ?? UIFont.systemFontSize)
            case 1:
                main = "Common name"
                detail = plant.commonName
            case 2:
                main = "Growing season(s)"
                detail = plant.printableGrowingSeason()
            case 3:
                main = "Dormant season(s)"
                detail = plant.printableDormantSeason()
            case 4:
                main = "Difficulty"
                if let difficulty = plant.difficulty { detail = String(difficulty.rawValue) }
            case 5:
                main = "Watering level(s)"
                detail = plant.printableWatering()
            case 6:
                main = "Lighting level(s)"
                detail = plant.printableLighting()
            default:
                main = nil
                detail = nil
            }
            cell.textLabel?.text = main
            cell.detailTextLabel?.text = detail
            return cell
        case linksTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath)
            cell.textLabel?.text = "TEST LINKS - row\(indexPath.row)"
            return cell
        default:
            fatalError("Unforeseen table view requesting a `UITableViewCell`")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case generalInfoTableView:
            return 50
        case linksTableView:
            return 75
        default:
            return 44
        }
    }
}




// add extension for Twicket segmented control
extension LibraryDetailViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch twicketSegementedControl.selectedSegmentIndex {
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
}
