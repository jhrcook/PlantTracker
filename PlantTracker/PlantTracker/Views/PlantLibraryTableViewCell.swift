//
//  PlantLibraryTableViewCell.swift
//  PlantTracker
//
//  Created by Joshua on 8/10/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class PlantLibraryTableViewCell: UITableViewCell {

    var plant = Plant(scientificName: nil, commonName: nil)
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var scientificNameLabel: UILabel!
    @IBOutlet var commonNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell() {
        setupConstraints()
        setupCellView()
    }
    
    func setupConstraints() {
        iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView)
            make.centerY.equalTo(contentView)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        scientificNameLabel = UILabel()
        contentView.addSubview(scientificNameLabel)
        scientificNameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right)
            make.centerY.equalTo(contentView)
        }

        commonNameLabel = UILabel()
        contentView.addSubview(commonNameLabel)
        commonNameLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
    }
    
    
    func setupCellView() {
        // main label
        if let scientificName = plant.scientificName {
            textLabel?.text = scientificName
        } else {
            textLabel?.text = "Unnamed"
            textLabel?.textColor = .gray
        }
        textLabel?.font = UIFont.italicSystemFont(ofSize: textLabel?.font.pointSize ?? UIFont.systemFontSize)
        
        // detail label
        detailTextLabel?.text = plant.commonName
        
        // cell image
        if imageView?.image == nil {
            var blankImage = UIImage(named: "blankImage")!
            blankImage = crop(image: blankImage, toWidth: 100, toHeight: 100)
            imageView?.image = resize(image: blankImage, targetSize: CGSize(width: 60, height: 60))
            imageView?.layer.masksToBounds = true
            imageView?.layer.cornerRadius = 30
        }

        if let iconImageID = plant.smallRoundProfileImage {
            // load profile image
            imageView?.layer.masksToBounds = true
            imageView?.layer.cornerRadius = 30
            imageView?.image = UIImage(contentsOfFile: getFilePathWith(id: iconImageID))
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak plant, weak self] in
                var image: UIImage?
                var usedCactusImage = false
                if let imageID = plant?.bestSingleImage() {
                    image = UIImage(contentsOfFile: getFilePathWith(id: imageID))
                }
                if image == nil {
                    usedCactusImage = true
                    image = UIImage(named: "cactusSmall")
                }
                image = crop(image: image!, toWidth: 100, toHeight: 100)
                image = resize(image: image!, targetSize: CGSize(width: 60, height: 60))
                
                // set image in main thread
                DispatchQueue.main.async {
                    self?.imageView?.layer.masksToBounds = true
                    self?.imageView?.layer.cornerRadius = 30
                    self?.imageView?.image = image
                }
                
                // save image for future use
                if !usedCactusImage {
                    let imageName = UUID().uuidString
                    let imagePath = getFileURLWith(id: imageName)
                    
                    if let jpegData = image!.jpegData(compressionQuality: 1.0) {
                        try? jpegData.write(to: imagePath)
                    }
                    plant?.smallRoundProfileImage = imageName
                }
            }
        }
    }


}
