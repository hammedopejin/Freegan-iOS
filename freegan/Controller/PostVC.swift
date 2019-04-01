//
//  PostVC.swift
//  freegan
//
//  Created by Hammed opejin on 3/19/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postDescription: FancyField!
    @IBAction func postButton(_ sender: Any) {
        
    }
    
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var cam: Camera?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        
        cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: imagePicker)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            postImage.image = image
            imageSelected = true
        } else {
            print("TAG: A valid image wasn't selected")
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
