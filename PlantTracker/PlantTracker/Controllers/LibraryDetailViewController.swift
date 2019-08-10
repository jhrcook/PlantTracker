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
    var plantsSaveDelegate: PlantsSaveDelegate?
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    var twicketSegementedControl: TwicketSegmentedControl!
    @IBOutlet var informationView: UIView!
    var floatyButton = Floaty()
    var generalInfoTableView: UITableView!
    var notesTextView: UITextView!
    var linksTableView: UITableView!
    
    let keyboard = KeyboardObserver()
    
    var startingYOffset: CGFloat? = nil
    
    var shouldDelete = false
    
    var headerImageIsSet = false
    
    var assetTracker = AssetIndexIDTracker()
    
    // height of header image
    let headerImageHeight = 350
    let minHeaderImageHeight = 100
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = plant.scientificName ?? plant.commonName ?? ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDetailAction))
        
        setupInformationTableViews()
        setupDetailView()
        didSelect(0)
        hideKeyboardWhenTappedAround()
        setupKeyboardObserver()
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
    
    
    func setupKeyboardObserver() {
        keyboard.observe { [weak self] (event) in
            
            // for notes text view editing
            if self?.notesTextView.isHidden == false {
                switch event.type {
                case .willHide:
                    self?.notesTextView.contentInset = .zero
                    
                    if self?.notesTextView.text == "" {
                        self?.notesTextView.text = "Notes"
                        self?.notesTextView.textColor = .lightGray
                    } else {
                        self?.plant.notes = self?.notesTextView.text ?? ""
                    }
                    
                case .willShow, .willChangeFrame:
                    let keyboardScreenFrameEnd = event.keyboardFrameEnd
                    let bottom = keyboardScreenFrameEnd.height - (self?.view.alignmentRectInsets.bottom)! + 8
                    self?.notesTextView.contentInset.bottom = bottom
                    
                    if self?.notesTextView.text == "Notes" {
                        self?.notesTextView.text = ""
                        self?.notesTextView.textColor = .black
                    }
                    
                    let scrollBottom = keyboardScreenFrameEnd.height
                    self?.mainScrollView.setContentOffset(CGPoint(x: 0, y: scrollBottom), animated: true)
                    
                default:
                    return
                }
            }
        }
        notesTextView.scrollIndicatorInsets = notesTextView.contentInset
        notesTextView.scrollRangeToVisible(notesTextView.selectedRange)
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
        setHeaderImage()
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
        
        // floatly button
        setUpFloatlyButton()
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
        
        // information view (below segmented control)
        informationView.snp.makeConstraints { (make) in
            make.top.equalTo(twicketSegementedControl.snp.bottom).offset(5)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        // information subviews
        notesTextView = UITextView()
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
        if plant.notes.count > 0 {
            notesTextView.text = plant.notes
            notesTextView.textColor = .black
        } else {
            notesTextView.text = "Notes"
            notesTextView.textColor = .lightGray
        }
        
        
        // initalize content height of main scroll view
        let contentHeight = CGFloat(headerImageHeight) + view.frame.height - CGFloat(minHeaderImageHeight)
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: contentHeight)
    }
    
    func setHeaderImage() {
        if let imageID = plant.bestSingleImage() {
            headerImageView.image = UIImage(contentsOfFile: getFilePathWith(id: imageID))
            headerImageIsSet = true
        } else {
            print("deafult header image")
            headerImageView.image = UIImage(named: "cactus")
        }
    }
}




extension LibraryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupInformationTableViews() {
        generalInfoTableView = UITableView.init(frame: CGRect.zero, style: .plain)
        generalInfoTableView.delegate = self
        generalInfoTableView.dataSource = self
        generalInfoTableView.register(GeneralInformtationTableViewCell.self, forCellReuseIdentifier: "generalInfoCell")
        generalInfoTableView.allowsSelection = false
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView {
        case generalInfoTableView:
            return true
        default:
            return false
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
            dismissKeyboard()
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
            dismissKeyboard()
        default:
            break
        }
    }
}



// to dismiss keyboard with taps anywhere else in view
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
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
//        let imageManager = PHImageManager.default()
//        let imageOptions = PHImageRequestOptions()
//
//        let defaults = UserDefaults.standard
//        switch defaults.string(forKey: "image quality") {
//        case "high":
//            imageOptions.deliveryMode = .highQualityFormat
//        case "medium":
//            imageOptions.deliveryMode = .opportunistic
//        case "low":
//            imageOptions.deliveryMode = .fastFormat
//        default:
//            imageOptions.deliveryMode = .highQualityFormat
//            print("value not entered for \"Image Quality\" setting.")
//        }
//        imageOptions.version = .current
//        imageOptions.isSynchronous = false
//        imageOptions.resizeMode = .exact
//
//        print("selected \(assets.count) images")
//        for asset in assets {
//            let assetSize = CGSize(width: Double(asset.pixelWidth), height: Double(asset.pixelHeight))
//            imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: addImageToPlant)
//        }
        for index in assetTracker.didNotDeleteAtRequestIndex {
            if let uuid = assetTracker.uuidFrom(indexPathItem: index) {
                print("deleting image uuid '\(uuid)' at index path '\(index)'")
                plant.deleteImage(at: uuid)
            }
        }
        assetTracker.reset()
        if let delegate = plantsSaveDelegate { delegate.savePlants() }
        setHeaderImage()
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
//                if !(self!.headerImageIsSet) {
//                    DispatchQueue.main.async { self?.setHeaderImage() }
//                }
                
//                if let delegate = self?.plantsSaveDelegate { delegate.savePlants() }
            }
        }
    }
    
}



// handle segues
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


// floaty button
extension LibraryDetailViewController {
    func setUpFloatlyButton() {
        
        // set self to delegate (maybe)
//        floatyButton.fabDelegate = self
        
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
}