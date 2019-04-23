//
//  EditPostVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/21/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class EditPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var firstPostImageView: UIImageView!
    @IBOutlet weak var secondPostImageView: UIImageView!
    @IBOutlet weak var thirdPostImageView: UIImageView!
    @IBOutlet weak var fourthPostImageView: UIImageView!
    @IBOutlet weak var postDescriptionText: FancyField!
    @IBOutlet weak var saveBottonView: FancyButton!
    
    var post: Post?
    var cam: Camera?
    var imagePicker: UIImagePickerController!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    
        
        
    }
    
    @IBAction func firstPostImageViewAction(_ sender: Any) {
        let flag = !(firstPostImageView.image == nil)
        showCameraLibraryOptions(deleteFlag: flag)
    }
    
    @IBAction func secondPostImageViewAction(_ sender: Any) {
        let flag = !(secondPostImageView.image == nil)
        showCameraLibraryOptions(deleteFlag: flag)
    }
    
    @IBAction func thirdPostImageViewAction(_ sender: Any) {
        let flag = !(thirdPostImageView.image == nil)
        showCameraLibraryOptions(deleteFlag: flag)
    }
    
    @IBAction func fourthPostImageViewAction(_ sender: Any) {
        let flag = !(fourthPostImageView.image == nil)
        showCameraLibraryOptions(deleteFlag: flag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        if let post = self.post {
            self.postDescriptionText.text = post.description
            
            var ref = Storage.storage().reference(forURL: post.imageUrl[0])
            
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
                    
                } else {
                    print("HAMMED: Image downloaded from Firebase storage, goood newwwws")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            
                            self.firstPostImageView.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl[0] as NSString)
                            
                        }
                    }
                }
            })
            
            if post.imageUrl.count > 1 {
                let secondImageUrl = post.imageUrl[1]
                if !secondImageUrl.isEmpty {
                    ref = Storage.storage().reference(forURL: secondImageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
                            
                        } else {
                            print("HAMMED: Image downloaded from Firebase storage, goood newwwws")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    
                                    self.secondPostImageView.image = img
                                    FeedVC.imageCache.setObject(img, forKey: secondImageUrl as NSString)
                                    
                                }
                            }
                        }
                    })
                }
            }
            
            if post.imageUrl.count > 2 {
                let thirdImageUrl = post.imageUrl[2]
                if !thirdImageUrl.isEmpty {
                    ref = Storage.storage().reference(forURL: thirdImageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
                            
                        } else {
                            print("HAMMED: Image downloaded from Firebase storage, goood newwwws")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    
                                    self.thirdPostImageView.image = img
                                    FeedVC.imageCache.setObject(img, forKey: thirdImageUrl as NSString)
                                    
                                }
                            }
                        }
                    })
                }
            }
            
            if post.imageUrl.count > 3 {
                let fourthImageUrl = post.imageUrl[3]
                if !fourthImageUrl.isEmpty {
                    ref = Storage.storage().reference(forURL: fourthImageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
                            
                        } else {
                            print("HAMMED: Image downloaded from Firebase storage, goood newwwws")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    
                                    self.fourthPostImageView.image = img
                                    FeedVC.imageCache.setObject(img, forKey: fourthImageUrl as NSString)
                                    
                                }
                            }
                        }
                    })
                }
            }
            
        }
    
    }

    
    
    func showCameraLibraryOptions(deleteFlag: Bool){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default){ (alert: UIAlertAction!) in
            self.cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default){ (alert: UIAlertAction!) in
            self.cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let deletelAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
        }
    
        optionMenu.addAction(camera)
        optionMenu.addAction(library)
        if deleteFlag {
            optionMenu.addAction(deletelAction)
        }
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}
