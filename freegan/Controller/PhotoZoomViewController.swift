//
//  PhotoZoomViewController.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var posterImageView: CircleView!
    @IBOutlet weak var postDescription: UITextField!
    
    var image: UIImage!
    var posterImage: UIImage!
    var postDescriptionText: String!
    var index: Int = 0
    var isRotating: Bool = false
    var firstTimeLoaded: Bool = true
    weak var toDelegate: ZoomAnimatorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.image
        self.posterImageView.image = self.posterImage
        postDescription.text = postDescriptionText
        
        self.imageView.frame = CGRect(x: self.imageView.frame.origin.x,
                                      y: self.imageView.frame.origin.y,
                                      width: imageView.bounds.width,
                                      height: imageView.bounds.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //updateZoomScaleForSize(view.bounds.size)
    }
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.isRotating = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
