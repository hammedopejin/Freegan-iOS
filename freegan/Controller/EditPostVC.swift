//
//  EditPostVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/21/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class EditPostVC: UIViewController, UITextFieldDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postDescriptionText.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        if let post = self.post {
            self.postDescriptionText.text = post.description
            self.postDescriptionText.sizeToFit()
            self.currentPostDownloadURLs = post.imageUrl
            self.toDeletePostDownloadURLs = [String]()
            self.tempImages = [UIImage]()
            self.imageRef = [StorageReference]()
            var ref = Storage.storage().reference(forURL: post.imageUrl[0])
            
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
                } else {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lockOrientation(.all)
    }
    
    @IBAction func backToPost(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
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
    
    func showCameraLibraryOptions(deleteFlag: Bool, index: Int){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let camera = UIAlertAction(title: "Camera", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let deletelAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (alert: UIAlertAction!) in
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
            hideViews()
            return
        }
        
        if (self.currentPostDownloadURLs!.count) < 1 {
            hideViews()
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
        
        self.showAlert(title: "Success!", message: "Post successfully updated.")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func hideViews() {
        self.removeSpinner()
        self.postDescriptionText.isHidden = false
        self.saveBottonView.isHidden = false
        self.firstPostImageView.isHidden = false
        self.secondPostImageView.isHidden = false
        self.thirdPostImageView.isHidden = false
        self.fourthPostImageView.isHidden = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension EditPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        picker.dismiss(animated: true, completion: nil)
    }
}
