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

/// Protocol for communicating with the main library view controller.
protocol LibraryDetailContainerDelegate {
    func setIcon(for plant: Plant)
}


class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    /// `Plant` object being displayed.
    var plant: Plant!
    
    /// An object that manages the array of `Plant` objects.
    var plantsManager: PlantsManager!
    
    /// Row being edited by the user.
    /// - TODO: make private
    var editingRowIndex: Int?
    
    /// An object that managers the editing row.
    /// - TODO: make private
    var editManager: EditPlantLevelManager?
    
    /// The parent library view controller delegate.
    var containerDelegate: LibraryDetailContainerDelegate!
    
    /// The main view of the `LibraryDetailViewController`.
    var libraryDetailView: LibraryDetailView! = nil
    /// The view controller for the table view showing the general plant information.
    let generalInfomationViewController = GeneralPlantInformationTableViewController()
    /// The view controller for the table view showing the links to reliable sources.
    let linksTableViewController = LinksTableViewController()
    
    /// An object for managing the keyboard notifications.
    ///
    /// - Note: This object is from the swift package ['KeyboardObserver'](https://github.com/morizotter/KeyboardObserver).
    /// - TODO: make private
    let keyboard = KeyboardObserver()
    
    /// The starting off-set for the scroll view for the parallax feature.
    ///
    /// - Note: This is a bit of a hack and can definitely be improved. That said, it works...
    /// - TODO: Make this private.
    var startingYOffset: CGFloat? = nil
    
    /// A notification to the parent view controller for whether to delete this plant when return to library.
    /// - TODO: Make this private(set) so cannot be changed by other, but can be seen.
    var shouldDelete = false
    
    /// A boolean value for whether the header image of the detail view was set.
    /// - TODO: make private
    var headerImageIsSet = false
    
    /// A manager of the assets (images) being loaded from the user's library.
    ///
    /// This manages the assets during active selection of the images in the image picker. When an image
    /// is selected, it is downloaded. When an image is unselected, it is removed. When the user either
    /// saves or cancels, the manager has the list of images to ensure are saved or deleted.
    /// - TODO: make private 
    var assetTracker = AssetIndexIDTracker()
    
    /// Blur effect for the header image.
    /// - TODO: Can this be moved to the `View`?
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
        
        // set up general information table view controller
        generalInfomationViewController.tableView = libraryDetailView.generalInfoTableView
        generalInfomationViewController.plant = plant
        generalInfomationViewController.plantsManager = plantsManager
        generalInfomationViewController.setupViewController()
        
        // set up links table view controller
        linksTableViewController.tableView = libraryDetailView.linksTableView
        linksTableViewController.plant = plant
        linksTableViewController.plantsManager = plantsManager
        
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
    
    /// Gets the header image for the plants.
    /// - returns: The best option for the header image of a plant.
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
    
    /// Adjust the view for vertical scrolling.
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
    
    /// An alert sheet is presented when the "Edit" navigation bar button is tapped.
    /// - TODO: make private.
    @objc func editDetailAction() {

        let alertController = UIAlertController(title: "Edit \(title ?? "plant")", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Add photos from library", style: .default, handler: addImages))
        alertController.addAction(UIAlertAction(title: "View photos", style: .default, handler: pushImageCollectionView))
        alertController.addAction(UIAlertAction(title: "Remove plant from library", style: .destructive, handler: removeFromLibrary))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        
    }
    
    /// Push to the collection view of all the plants images.
    /// - TODO: make private
    func pushImageCollectionView(_ alert: UIAlertAction) {
        os_log("Performing segue with identifier: 'showImageCollectionView'.", log: Log.detailLibraryVC, type: .default)
        performSegue(withIdentifier: "showImageCollectionView", sender: self)
    }
    
    /// A second check that the user wants to delete the plant from their library. Selecting "Remove" pops
    /// back to the plant library with `shouldDelete` set to `true`.
    /// - TODO: make private
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


// MARK: TwicketSegmentedControlDelegate

extension LibraryDetailViewController: TwicketSegmentedControlDelegate {
    /// Adjusting the information view based on the selectino of the segmented controller.
    /// - Note: This object is from the swift package ['TwicketSegmentedControl'](https://github.com/twicketapp/TwicketSegmentedControl).
    /// - TODO: For iOS 13, change to standard segmented controller.
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
    
    /// The text view is either blank or has content.
    enum TextViewState {
        case blank, content
    }
    
    /// If the text view is blank, grey text is added to indicate that the user can add "Notes". Otherwise, the
    /// text color is set to black.
    /// - TODO: for iOS 13, update to `UIColor.label`.
    /// - TODO: make private
    func setNotesTextView(to textViewState: TextViewState) {
        switch textViewState {
        case .blank:
            libraryDetailView.notesTextView.text = "Notes"
            libraryDetailView.notesTextView.textColor = .lightGray
        case .content:
            libraryDetailView.notesTextView.textColor = .black
        }
    }
    
    /// Set up the text view with the notes of a `Plant` object
    /// - TODO: make private
    func setupNotesView() {
        if plant.notes.count > 0 {
            setNotesTextView(to: .content)
            libraryDetailView.notesTextView.text = plant.notes
        } else {
            setNotesTextView(to: .blank)
        }
    }
    
    /// Set up the `KeyboardObserver` object.
    /// - TODO: make private
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
    
    /// Set a tap gesture to hide the keyboard.
    /// - TODO: make private
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LibraryDetailViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /// Dismiss the keyboard by calling `view.endEditing(true)`.
    /// - TODO: Write a quick tutorial for using `KeyboardObserver` for my website.
    /// - TODO: make private
    @objc func dismissKeyboard() {
        os_log("Hiding the keyboard.", log: Log.detailLibraryVC, type: .info)
        view.endEditing(true)
    }
}



// MARK: UINavigationControllerDelegate

extension LibraryDetailViewController: UINavigationControllerDelegate {
    
    /// Add an image for the plant.
    /// - TODO: make private
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
    /// Called when the user is done selecting images.
    /// It checks for a new header image and calls the library view controller to set the icon.
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
