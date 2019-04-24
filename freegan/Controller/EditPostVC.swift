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
    var currentPostDownloadURLs: [String]?
    var toDeletePostDownloadURLs: [String]?
    var tempImageView: UIImageView?
    var tempImages: [UIImage]?
    var imageRef: [StorageReference]?
    var currentIndex = 0
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if self.postDescriptionText.text == "" {
            showToast(message: "Post needs description!")
            return
        }
        
        self.postToFirebase()
    }
    
    @IBAction func firstPostImageViewAction(_ sender: Any) {
        self.currentIndex = 0
        self.tempImageView = firstPostImageView
        let flag = !(self.tempImageView!.image == nil)
        showCameraLibraryOptions(deleteFlag: flag, index: self.currentIndex)
    }
    
    @IBAction func secondPostImageViewAction(_ sender: Any) {
        self.currentIndex = 1
        self.tempImageView = secondPostImageView
        let flag = !(self.tempImageView!.image == nil)
        showCameraLibraryOptions(deleteFlag: flag, index: self.currentIndex)
    }
    
    @IBAction func thirdPostImageViewAction(_ sender: Any) {
        self.currentIndex = 2
        self.tempImageView = thirdPostImageView
        let flag = !(self.tempImageView!.image == nil)
        showCameraLibraryOptions(deleteFlag: flag, index: self.currentIndex)
    }
    
    @IBAction func fourthPostImageViewAction(_ sender: Any) {
        self.currentIndex = 3
        self.tempImageView = fourthPostImageView
        let flag = !(self.tempImageView!.image == nil)
        showCameraLibraryOptions(deleteFlag: flag, index: self.currentIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        if let post = self.post {
            self.postDescriptionText.text = post.description
            self.currentPostDownloadURLs = post.imageUrl
            self.toDeletePostDownloadURLs = [String]()
            self.tempImages = [UIImage]()
            self.imageRef = [StorageReference]()
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

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if !(self.tempImageView!.image == nil) {
                self.deleteImage(index: self.currentIndex)
            }
            self.tempImageView!.image = image
            self.tempImages!.append(image)
        } else {
            print("TAG: A valid image wasn't selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func showCameraLibraryOptions(deleteFlag: Bool, index: Int){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default){ (alert: UIAlertAction!) in
            self.cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default){ (alert: UIAlertAction!) in
            self.cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let deletelAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) in
            self.deleteImage(index: index)
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

    func postToFirebase() {
        self.showSpinner(onView: self.view)
        self.postDescriptionText.isHidden = true
        self.saveBottonView.isHidden = true
        self.firstPostImageView.isHidden = true
        self.secondPostImageView.isHidden = true
        self.thirdPostImageView.isHidden = true
        self.fourthPostImageView.isHidden = true
        
        if self.tempImages!.count > 0 {
            for (index, img) in self.tempImages!.enumerated() {
                
                if let imgData = img.jpegData(compressionQuality: 0.2) {
                    
                    let imgUid = NSUUID().uuidString
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    self.imageRef!.append(DataService.ds.REF_POST_IMAGES.child(imgUid))
                    let finalI: Int  = index
                    
                    let _ = self.imageRef![finalI].putData(imgData, metadata: metadata) { (metadata, error) in
    
                        self.imageRef![finalI].downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                return
                            }
                        
                            self.currentPostDownloadURLs!.append(downloadURL.absoluteString)
                            if finalI == (self.tempImages!.count - 1) {
                                print(finalI == (self.tempImages!.count - 1))
                                self.postIt()
                            }
                        }
                    }
                }
            }
        } else {
            self.postIt()
        }
        
    }
    
    func deleteImage(index: Int){
        switch index {
        case 0:
            firstPostImageView.image = nil
            self.toDeletePostDownloadURLs!.append(post!.imageUrl[0])
            break
            
        case 1:
            secondPostImageView.image = nil
            self.toDeletePostDownloadURLs!.append(post!.imageUrl[1])
            break
            
        case 2:
            thirdPostImageView.image = nil
            self.toDeletePostDownloadURLs!.append(post!.imageUrl[2])
            break
            
        case 3:
            fourthPostImageView.image = nil
            self.toDeletePostDownloadURLs!.append(post!.imageUrl[3])
            break
            
        default: break
            
        }
    }
    
    func postIt(){
        
        self.currentPostDownloadURLs!.removeAll(where: { self.toDeletePostDownloadURLs!.contains($0) })
        
        if self.postDescriptionText.text == self.post!.description, self.currentPostDownloadURLs == post!.imageUrl {
            self.removeSpinner()
            self.postDescriptionText.isHidden = false
            self.saveBottonView.isHidden = false
            self.firstPostImageView.isHidden = false
            self.secondPostImageView.isHidden = false
            self.thirdPostImageView.isHidden = false
            self.fourthPostImageView.isHidden = false
            return
        }
        
        if (self.currentPostDownloadURLs!.count) < 1 {
            self.removeSpinner()
            self.postDescriptionText.isHidden = false
            self.saveBottonView.isHidden = false
            self.firstPostImageView.isHidden = false
            self.secondPostImageView.isHidden = false
            self.thirdPostImageView.isHidden = false
            self.fourthPostImageView.isHidden = false
            showToast(message: "At least one image is needed to post!")
            return
        }
        
        for currentUrl in self.toDeletePostDownloadURLs! {
            let storageRef = storage.reference(forURL: currentUrl)
            storageRef.delete(completion: nil)
        }
        
        let date = Date()
        let time = dateFormatterWithTime().string(from: date)
        
        let reference = firebase.child(kPOST).child(self.post!.postId)
        
        var values = [kDESCRIPTION : self.postDescriptionText.text as AnyObject, kPOSTDATE: time as AnyObject]
        
        reference.updateChildValues(values)
        reference.child(kIMAGEURL).setValue(self.currentPostDownloadURLs!)
        
        values.removeAll()
        self.tempImages!.removeAll()
        self.imageRef!.removeAll()
        self.currentPostDownloadURLs!.removeAll()
        self.toDeletePostDownloadURLs!.removeAll()
        self.removeSpinner()
        
        self.showAlert("Success!", message: "Post successfully updated.")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
