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
import KeyboardObserver
import AssetsPickerViewController
import Floaty
import os




class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var plant: Plant!
    var plantsDelegate: PlantsDelegate?
    
    var libraryDetailView: LibraryDetailView! = nil
    
    let keyboard = KeyboardObserver()
    
    var startingYOffset: CGFloat? = nil
    
    var shouldDelete = false
    
    var headerImageIsSet = false
    
    var assetTracker = AssetIndexIDTracker()
    
    var blurEffectView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryDetailView = LibraryDetailView()
        view.addSubview(libraryDetailView)
        libraryDetailView.snp.makeConstraints { make in make.edges.equalTo(self.view) }
        libraryDetailView.frame = self.view.frame
        libraryDetailView.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0
        
        libraryDetailView.headerImage = getHeaderImage()
        
        libraryDetailView.setupView()
        
        libraryDetailView.mainScrollView.delegate = self
        libraryDetailView.twicketSegementedControl.delegate = self
        libraryDetailView.generalInfoTableView.delegate = self
        libraryDetailView.generalInfoTableView.dataSource = self
        libraryDetailView.linksTableView.delegate = self
        libraryDetailView.linksTableView.dataSource = self
        
        title = plant.scientificName ?? plant.commonName ?? ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDetailAction))
        
        didSelect(0)
        hideKeyboardWhenTappedAround()
        setupKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("View will appear.", log: Log.detailLibraryVC, type: .debug)
        libraryDetailView.headerImage = getHeaderImage()
        plantsDelegate?.savePlants()
    }
    
    
    func getHeaderImage() -> UIImage? {
        os_log("Retrieving header image.", log: Log.detailLibraryVC, type: .info)
        if let imageID = plant.bestSingleImage() {
            headerImageIsSet = true
            return UIImage(contentsOfFile: getFilePathWith(id: imageID))
        } else {
            os_log("Returning default 'cactus' image.", log: Log.detailLibraryVC, type: .info)
            return UIImage(named: "cactus")
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == libraryDetailView.mainScrollView && libraryDetailView.startingYOffset == nil {
            // initialize starting Y offset
            libraryDetailView.startingYOffset = scrollView.contentOffset.y
            os_log("Setting initial starting Y offset as %d.", log: Log.detailLibraryVC, type: .info, libraryDetailView.startingYOffset!)
        }
        
        if scrollView == libraryDetailView.mainScrollView {
            libraryDetailView.updateHeaderImage(offset: scrollView.contentOffset)
        }
    }
    
    
    @objc func editDetailAction() {

        let alertController = UIAlertController(title: "Edit \(title ?? "plant")", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Add photos from library", style: .default, handler: addImages))
        alertController.addAction(UIAlertAction(title: "View photos", style: .default, handler: pushImageCollectionView))
        alertController.addAction(UIAlertAction(title: "Remove plant from library", style: .destructive, handler: removeFromLibrary))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        
    }
    
    
    func pushImageCollectionView(_ alert: UIAlertAction) {
        os_log("Performing segue with identifier: 'showImageCollectionView'.", log: Log.detailLibraryVC, type: .default)
        performSegue(withIdentifier: "showImageCollectionView", sender: self)
    }
    
    
    func removeFromLibrary(_ alert: UIAlertAction) {
        let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
        let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
        alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.shouldDelete = true
            self?.performSegue(withIdentifier: "unwindToLibraryTableView", sender: self)
            os_log("Sending signal to remove plant.", log: Log.detailLibraryVC, type: .default)
        })
        present(alertControler, animated: true)
    }
}




extension LibraryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case libraryDetailView.generalInfoTableView:
            return 7
        case libraryDetailView.linksTableView:
            return 3
        default:
            os_log("Unforseen table view requesting some number of cells.", log: Log.detailLibraryVC, type: .error)
            fatalError("Unforeseen table view requesting number of cells")
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case libraryDetailView.generalInfoTableView:
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
        case libraryDetailView.linksTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath)
            cell.textLabel?.text = "TEST LINKS - row\(indexPath.row)"
            return cell
        default:
            os_log("Unforseen table view requesting a `UITableViewCell`.", log: Log.detailLibraryVC, type: .error)
            fatalError("Unforeseen table view requesting a `UITableViewCell`")
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case libraryDetailView.generalInfoTableView:
            return 50
        case libraryDetailView.linksTableView:
            return 75
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView {
        case libraryDetailView.generalInfoTableView:
            return true
        default:
            return false
        }
    }
}




// MARK: TwicketSegmentedControlDelegate

extension LibraryDetailViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        os_log("Twicket segmented controller set to %d", log: Log.detailLibraryVC, type: .info, segmentIndex)
        switch libraryDetailView.twicketSegementedControl.selectedSegmentIndex {
        case 0:
            // "Information"
            libraryDetailView.generalInfoTableView.isHidden = false
            libraryDetailView.notesTextView.isHidden = true
            libraryDetailView.linksTableView.isHidden = true
            dismissKeyboard()
        case 1:
            // "Notes"
            libraryDetailView.generalInfoTableView.isHidden = true
            libraryDetailView.notesTextView.isHidden = false
            libraryDetailView.linksTableView.isHidden = true
        case 2:
            // "Links"
            libraryDetailView.generalInfoTableView.isHidden = true
            libraryDetailView.notesTextView.isHidden = true
            libraryDetailView.linksTableView.isHidden = false
            dismissKeyboard()
        default:
            break
        }
    }
}



// MARK: Keyboard

extension LibraryDetailViewController {
    
    func setupKeyboardObserver() {
        keyboard.observe { [weak self] (event) in
            
            // for notes text view editing
            if self?.libraryDetailView.notesTextView.isHidden == false {
                switch event.type {
                case .willHide:
                    self?.libraryDetailView.notesTextView.contentInset = .zero
                    
                    if self?.libraryDetailView.notesTextView.text == "" {
                        self?.libraryDetailView.notesTextView.text = "Notes"
                        self?.libraryDetailView.notesTextView.textColor = .lightGray
                    } else {
                        self?.plant.notes = self?.libraryDetailView.notesTextView.text ?? ""
                    }
                    
                case .willShow, .willChangeFrame:
                    let keyboardScreenFrameEnd = event.keyboardFrameEnd
                    let bottom = keyboardScreenFrameEnd.height - (self?.view.alignmentRectInsets.bottom)! + 8
                    self?.libraryDetailView.notesTextView.contentInset.bottom = bottom
                    
                    if self?.libraryDetailView.notesTextView.text == "Notes" {
                        self?.libraryDetailView.notesTextView.text = ""
                        self?.libraryDetailView.notesTextView.textColor = .black
                    }
                    
                    let scrollBottom = keyboardScreenFrameEnd.height
                    self?.libraryDetailView.mainScrollView.setContentOffset(CGPoint(x: 0, y: scrollBottom), animated: true)
                    
                default:
                    return
                }
            }
        }
        libraryDetailView.notesTextView.scrollIndicatorInsets = libraryDetailView.notesTextView.contentInset
        libraryDetailView.notesTextView.scrollRangeToVisible(libraryDetailView.notesTextView.selectedRange)
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LibraryDetailViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        os_log("Hiding the keyboard.", log: Log.detailLibraryVC, type: .info)
        view.endEditing(true)
    }
}



// MARK: UINavigationControllerDelegate

extension LibraryDetailViewController: UINavigationControllerDelegate {
    
    @objc func addImages(_ alert: UIAlertAction) {
        let imagePicker = PlantAssetsPickerViewController()
        imagePicker.plant = plant
        imagePicker.didFinishDelegate = self
        
        os_log("Presenting asset image picker.", log: Log.detailLibraryVC, type: .info)
        
        present(imagePicker, animated: true)
    }
    
}



// MARK: AssetPickerFinishedSelectingDelegate

extension LibraryDetailViewController: AssetPickerFinishedSelectingDelegate {
    func didFinishSelecting(assetPicker: PlantAssetsPickerViewController) {
        os_log("AssetPickerFinishedSelectingDelegate is running `didFinishSelecting(assetPicker:)` method.", log: Log.detailLibraryVC, type: .info)
        libraryDetailView.headerImage = getHeaderImage()
        plantsDelegate?.setIcon(for: plant)
        plantsDelegate?.savePlants()
    }
}



// MARK: segue

extension LibraryDetailViewController {
    
    // seque into image collection view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageCollectionViewController {
            os_log("Sending images to `ImageCollectionViewController`.", log: Log.detailLibraryVC, type: .default)
            vc.plant = plant
            vc.plantsDelegate = self.plantsDelegate
            vc.title = self.title
        }
    }
}
