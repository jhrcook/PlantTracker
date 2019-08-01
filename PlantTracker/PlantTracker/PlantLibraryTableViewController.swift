//
//  ViewController.swift
//  PlantTracker
//
//  Created by Joshua on 7/12/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewController: UITableViewController {

    var plants = [Plant]()
    // Example `plants` data
    
    var lastSelectedRow: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newPlant))
        
        loadPlants()
        // Do any additional setup after loading the view.
        
        // TESTING
        if (plants.count == 0 || false) {
            print("loading test plants")
            plants = [
                Plant(scientificName: "Euphorbia obesa", commonName: "Basball cactus"),
                Plant(scientificName: "Frailea castanea", commonName: "Kirsten"),
                Plant(scientificName: nil, commonName: "split rock"),
                Plant(scientificName: "Lithops julii", commonName: nil),
                Plant(scientificName: nil, commonName: nil),
            ]
        }
        ///////////
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savePlants()
        
        // so that image views are updated
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)
        let cellPlant = plants[indexPath.row]
        
        // main label
        if let scientificName = cellPlant.scientificName {
            cell.textLabel?.text = scientificName
        } else {
            cell.textLabel?.text = "Unnamed"
            cell.textLabel?.textColor = .gray
        }
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: cell.textLabel?.font.pointSize ?? UIFont.systemFontSize)
        
        // detail label
        cell.detailTextLabel?.text = cellPlant.commonName
        
        // cell image
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            var image: UIImage?
            if let imageName = cellPlant.bestSingleImage() { image = UIImage(contentsOfFile: imageName) }
            if image == nil { image = UIImage(named: "cactus") }
            image = self?.crop(image: image!, toWidth: 100, toHeight: 100)
            image = self?.resize(image: image!, targetSize: CGSize(width: 60, height: 60))
            
            // set image in main thread
            DispatchQueue.main.async {
                cell.imageView?.layer.cornerRadius = 30
                cell.imageView?.layer.masksToBounds = true
                cell.imageView?.image = image
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func savePlants() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(plants) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "plants")
            print("Saved plants.")
        } else {
            print("Failed to save plants.")
        }
    }
    
    
    func loadPlants() {
        let defaults = UserDefaults.standard
        if let savedPlants = defaults.object(forKey: "plants") as? Data{
            let jsonDecoder = JSONDecoder()
            do {
                plants = try jsonDecoder.decode([Plant].self, from: savedPlants)
                print("Loaded \(plants.count) plants.")
            } catch {
                print("Failed to load `plants`")
            }
        }
    }
    
    
    @objc func newPlant() {
        // add new (blank) plant instance
        plants.append(Plant(scientificName: nil, commonName: nil))
        savePlants()
        tableView.reloadData()
        
        // "select" the new row in the table view
        let indexPath = IndexPath(row: plants.count-1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = plants[indexPath.row]
            if UserDefaults.standard.bool(forKey: "in safe mode") {
                let message = "Are you sure you want to remove \(title ?? "this plant") from your library?"
                let alertControler = UIAlertController(title: "Remove plant?", message: message, preferredStyle: .alert)
                alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertControler.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self, weak plant] _ in
                    plant?.deleteAllImages()
                    self?.plants.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                })
                present(alertControler, animated: true)
            } else {
                plant.deleteAllImages()
                plants.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
        savePlants()
    }
}


// handle segues
extension PlantLibraryTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LibraryDetailViewController {
            if plants.count > 0, let index = tableView.indexPathForSelectedRow?.row {
                print("sending index: \(index)")
                vc.plant = plants[index]
            }
        }
    }
    
    
    @IBAction func unwindToLibraryTableView(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? LibraryDetailViewController else { return }
        
        // Indicated that this plant should be removed in the detail view controller
        if sourceViewController.shouldDelete, let rowToDelete = lastSelectedRow {
            let indexPath = IndexPath(row: rowToDelete, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, commit: .delete, forRowAt: indexPath)
        }
    }
}


// adjust an image
extension UIViewController {
    func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func crop(image: UIImage, toWidth width: Double, toHeight height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}


