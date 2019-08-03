//
//  ImagePagingViewController.swift
//  PlantTracker
//
//  Created by Joshua on 8/3/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class ImagePagingViewController: UIViewController {

    var startingIndex: Int = 0
    var images = [UIImage]()
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupMainScrollView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// set up inital view
extension ImagePagingViewController {
    func setupMainScrollView() {
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        mainScrollView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        mainScrollView.contentSize = CGSize(width: viewWidth * CGFloat(images.count), height: viewHeight)
        mainScrollView.isPagingEnabled = true
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.alwaysBounceVertical = false
        mainScrollView.alwaysBounceHorizontal = true
        mainScrollView.isDirectionalLockEnabled = true
        
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        for i in 0..<images.count {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: viewWidth * CGFloat(i), y: 0, width: viewWidth, height: viewHeight)
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            mainScrollView.addSubview(imageView)
        }
    }
}
