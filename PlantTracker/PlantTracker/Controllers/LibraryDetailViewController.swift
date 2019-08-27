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


protocol LibraryDetailContainerDelegate {
    func setIcon(for plant: Plant)
}


class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var plant: Plant!
    var plantsManager: PlantsManager!
    
    var containerDelegate: LibraryDetailContainerDelegate!
    
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
        
        setupNotesView()
        
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
        plantsManager.savePlants()
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == libraryDetailView.generalInfoTableView {
            switch indexPath.row {
            case 0:
                // "Scientific name"
                getNewName(for: .scientificName)
            case 1:
                // "Common name"
                getNewName(for: .commonName)
            case 2:
                // "Growing season(s)"
                setLevelOf(plantLevel: .growingSeason)
                break
            case 3:
                // "Dormant season(s)"
                break
            case 4:
                // "Difficulty"
                setDifficultyLevel()
            case 5:
                // "Watering level(s)"
                break
            case 6:
                // "Lighting level(s)"
                break
            default:
                break
            }
        }
    }
    
    
    enum PlantName { case scientificName, commonName }
    
    func getNewName(for plantName: PlantName) {
        let alertTitle = "Change the plant's \(plantName == .commonName ? "common name" : "scientific name")"
        let ac = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        ac.addTextField()
        switch plantName {
        case .scientificName:
            ac.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
                if let newName = ac.textFields?[0].text {
                    self?.plant.scientificName = newName
                    self?.title = newName
                    self?.reloadGeneralInfoTableViewAndSavePlants()
                }
            })
        case .commonName:
            ac.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
                if let newName = ac.textFields?[0].text {
                    self?.plant.commonName = newName
                    self?.reloadGeneralInfoTableViewAndSavePlants()
                }
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    
    enum PlantLevel: String {
        case growingSeason = "Growing Season"
        case dormantSeason = "Dormant Season"
        case wateringLevel = "Watering Level"
        case lightingLevel = "Lighting Level"
    }
    
    func setLevelOf(plantLevel: PlantLevel) {
        // have a drop-down menu with segmented controller
    }
    
    
    func setDifficultyLevel() {
        let ac = UIAlertController(title: "Set difficulty level", message: nil, preferredStyle: .alert)
        for level in DifficultyLevel.allCases {
            let alert = UIAlertAction(title: level.rawValue, style: .default) { _ in
                self.plant.difficulty = level
                self.reloadGeneralInfoTableViewAndSavePlants()
            }
            ac.addAction(alert)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    
    func reloadGeneralInfoTableViewAndSavePlants() {
        libraryDetailView.generalInfoTableView.reloadData()
        plantsManager.savePlants()
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
    
    enum TextViewState {
        case blank, content
    }
    
    
    func setNotesTextView(to textViewState: TextViewState) {
        
        switch textViewState {
        case .blank:
            libraryDetailView.notesTextView.text = "Notes"
            libraryDetailView.notesTextView.textColor = .lightGray
        case .content:
            libraryDetailView.notesTextView.textColor = .black
        }
    }
    
    
    func setupNotesView() {
        if plant.notes.count > 0 {
            setNotesTextView(to: .content)
            libraryDetailView.notesTextView.text = plant.notes
        } else {
            setNotesTextView(to: .blank)
        }
    }
    
    
    func setupKeyboardObserver() {
        keyboard.observe { [weak self] (event) in
            
            // for notes text view editing
            if self?.libraryDetailView.notesTextView.isHidden == false {
                switch event.type {
                case .willHide:
                    os_log("Keyboard will hide", log: Log.detailLibraryVC, type: .info)
                    self?.libraryDetailView.notesTextView.contentInset = .zero
                    
                    if self?.libraryDetailView.notesTextView.text == "" {
                        self?.setNotesTextView(to: .blank)
                    } else {
                        self?.plant.notes = self?.libraryDetailView.notesTextView.text ?? ""
                        self?.plantsManager.savePlants()
                    }
                    
                case .willShow, .willChangeFrame:
                    os_log("Keyboard will show/change frame", log: Log.detailLibraryVC, type: .info)
                    let keyboardScreenFrameEnd = event.keyboardFrameEnd
                    let bottom = keyboardScreenFrameEnd.height - (self?.view.alignmentRectInsets.bottom)! + 8
                    self?.libraryDetailView.notesTextView.contentInset.bottom = bottom
                    
                    if self?.libraryDetailView.notesTextView.text == "Notes" {
                        self?.libraryDetailView.notesTextView.text = ""
                        self?.setNotesTextView(to: .content)
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
        containerDelegate.setIcon(for: plant)
        plantsManager.savePlants()
    }
}



// MARK: segue

extension LibraryDetailViewController {
    
    // seque into image collection view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageCollectionViewController {
            os_log("Sending images to `ImageCollectionViewController`.", log: Log.detailLibraryVC, type: .default)
            vc.plant = plant
            vc.plantsManager = self.plantsManager
            vc.title = self.title
        }
    }
}
