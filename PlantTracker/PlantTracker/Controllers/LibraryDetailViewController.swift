//
//  LibraryDetailViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/14/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import TwicketSegmentedControl
import KeyboardObserver
import AssetsPickerViewController
import Floaty

class LibraryDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var plant: Plant!
    var plantsSaveDelegate: PlantsDelegate?
    
    var libraryDetailView: LibraryDetailView! = nil
    
    let keyboard = KeyboardObserver()
    
    var startingYOffset: CGFloat? = nil
    
    var shouldDelete = false
    
    var headerImageIsSet = false
    
    var assetTracker = AssetIndexIDTracker()
    
    var blurEffectView: UIVisualEffectView!
    
    
//    override func loadView() {
//
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryDetailView = LibraryDetailView()
        view.addSubview(libraryDetailView)
        libraryDetailView.snp.makeConstraints { make in make.edges.equalTo(view) }
        
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
    
    
    func getHeaderImage() -> UIImage? {
        if let imageID = plant.bestSingleImage() {
            headerImageIsSet = true
            return UIImage(contentsOfFile: getFilePathWith(id: imageID))
        } else {
            print("deafult header image")
            return UIImage(named: "cactus")
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrolling - x: \(scrollView.contentOffset.x), y: \(scrollView.contentOffset.y)")
        
        if scrollView == libraryDetailView.mainScrollView && libraryDetailView.startingYOffset == nil {
            // initialize starting Y offset
            libraryDetailView.startingYOffset = scrollView.contentOffset.y
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
        performSegue(withIdentifier: "showImageCollectionView", sender: self)
    }
    
    
    func removeFromLibrary(_ alert: UIAlertAction) {
        let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
        let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
        alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.shouldDelete = true
            self?.performSegue(withIdentifier: "unwindToLibraryTableView", sender: self)
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
        view.endEditing(true)
    }
}



extension LibraryDetailViewController: AssetsPickerViewControllerDelegate, UINavigationControllerDelegate {
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        print("Need permission to access photo library.")
    }
    
    
    @objc func addImages(_ alert: UIAlertAction) {
        
        // filter to only show photos
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetFetchOptions = [
            .album: options,
            .smartAlbum: options
        ]
        
        let imagePicker = AssetsPickerViewController()
        imagePicker.pickerDelegate = self
        imagePicker.pickerConfig = pickerConfig
        
        print("opening image picker")
        present(imagePicker, animated: true)
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
        let imageManager = PHImageManager.default()
        let imageOptions = PHImageRequestOptions()
        
        let defaults = UserDefaults.standard
        switch defaults.string(forKey: "image quality") {
        case "high":
            imageOptions.deliveryMode = .highQualityFormat
        case "medium":
            imageOptions.deliveryMode = .opportunistic
        case "low":
            imageOptions.deliveryMode = .fastFormat
        default:
            imageOptions.deliveryMode = .highQualityFormat
            print("value not entered for \"Image Quality\" setting.")
        }
        imageOptions.version = .current
        imageOptions.isSynchronous = false
        imageOptions.resizeMode = .exact
        
        let assetSize = CGSize(width: Double(asset.pixelWidth), height: Double(asset.pixelHeight))
        let requestIndex = imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: addImageToPlant)
        assetTracker.add(requestIndex: Int(requestIndex), withIndexPathItem: indexPath.item)
        print("saving request ID '\(requestIndex)' to index path '\(indexPath.item)'")
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
        if let uuid = assetTracker.uuidFrom(indexPathItem: indexPath.item) {
            print("deleting image uuid '\(uuid)' at index path '\(indexPath.item)'")
            plant.deleteImage(at: uuid)
        } else {
            assetTracker.didNotDeleteAtRequestIndex.append(indexPath.item)
        }
    }
    
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for index in assetTracker.didNotDeleteAtRequestIndex {
            if let uuid = assetTracker.uuidFrom(indexPathItem: index) {
                print("deleting image uuid '\(uuid)' at index path '\(index)'")
                plant.deleteImage(at: uuid)
            }
        }
        assetTracker.reset()
        if let delegate = plantsSaveDelegate { delegate.savePlants() }
        libraryDetailView.headerImage = getHeaderImage()
    }
    
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        print("user canceled asset getting")
        if let allUUIDs = assetTracker.allUUIDs() {
            for uuid in allUUIDs {
                print("deleting UUID '\(uuid)'")
                plant.deleteImage(at: uuid)
            }
        }
        assetTracker.reset()
    }
    
    
    func addImageToPlant(image: UIImage?, info: [AnyHashable: Any]?) {
        
        if let image = image {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let uuid = UUID().uuidString
                print("saving image: \(uuid)")
                let imageURL = getFileURLWith(id: uuid)
                
                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    try? jpegData.write(to: imageURL)
                }
                self?.plant.images.append(uuid)
                if let info = info, let requestIndex = info["PHImageResultRequestIDKey"] as? Int {
                    print("setting uuid '\(uuid)' as request index '\(requestIndex)'")
                    self?.assetTracker.add(uuid: uuid, withRequestIndex: requestIndex)
                } else {
                    print("failed to set request index for image UUID, dumping `info`:")
                    print("-----------------")
                    if let info = info { print(info) }
                    print("-----------------")
                }
            }
        }
    }
    
}



// MARK: segue

extension LibraryDetailViewController {
    
    // seque into image collection view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageCollectionViewController {
            print("sending \(plant.images.count) images")
            vc.imageIDs = plant.images
            vc.title = self.title
        }
    }
}
