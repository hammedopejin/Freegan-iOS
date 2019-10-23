//
//  PostVC.swift
//  freegan
//
//  Created by Hammed opejin on 3/19/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class PostVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postDescription: FancyField!
    @IBOutlet weak var postButtonView: FancyButton!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    static var useCamera = false
    var cam: Camera?
    var currentUser: FUser?
    var geoRef: GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postDescription.delegate = self
        geoRef = GeoFire(firebaseRef: firebase.child(kPOSTLOCATION))
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        if PostVC.useCamera{
            cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: imagePicker)
        } else {
            cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: imagePicker)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.hidesBarsOnTap = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let img = postImage.image, imageSelected == true else {
            showToast(message: "An image must be selected!")
            return
        }
        guard let description = postDescription.text, description != "" else {
            showToast(message: "Item must have description!")
            return
        }
        
        self.view.endEditing(true)
        postButtonView.isHidden = true
        postDescription.isHidden = true
        showSpinner(onView: view)
        
        if let imgData = img.jpegData(compressionQuality: 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let ref = DataService.ds.REF_POST_IMAGES.child(imgUid)
            
            let _ = ref.putData(imgData, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let _ = metadata.size
                // You can also access to download URL after upload.
                ref.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        
                        return
                    }
                    self.postToFirebase(imgUrl: downloadURL.absoluteString)
                }
            }
        }
    }
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let img = postImage.image, imageSelected == true else {
            showToast(message: "An image must be selected!")
            return
        }
        guard let description = postDescription.text, description != "" else {
            showToast(message: "Item must have description!")
            return
        }
        
        self.view.endEditing(true)
        postButtonView.isHidden = true
        postDescription.isHidden = true
        showSpinner(onView: view)
        
        if let imgData = img.jpegData(compressionQuality: 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let ref = DataService.ds.REF_POST_IMAGES.child(imgUid)
            
            let _ = ref.putData(imgData, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let _ = metadata.size
                // You can also access to download URL after upload.
                ref.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        
                        return
                    }
                    self.postToFirebase(imgUrl: downloadURL.absoluteString)
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let date = Date()
        let time = dateFormatterWithTime().string(from: date)
        
        let postRef = DataService.ds.REF_POSTS.childByAutoId()
        let postId: String = postRef.key!
        
        let post: Dictionary<String, AnyObject> = [
            kPOSTID : postId as AnyObject,
            kDESCRIPTION : postDescription.text! as AnyObject,
            kIMAGEURL : [imgUrl] as AnyObject,
            kPROFILEIMAGEURL : currentUser!.userImgUrl as AnyObject,
            kUSERNAME : self.currentUser!.userName as AnyObject,
            kPOSTDATE : time as AnyObject,
            kPOSTUSEROBJECTID : currentUser!.objectId as AnyObject
        ]
        
        postRef.setValue(post)
        geoRef?.setLocation(CLLocation(latitude: (currentUser?.latitude)!, longitude: (currentUser?.longitude)!), forKey: postId)
        
        self.removeSpinner()
        postDescription.text = ""
        imageSelected = false
        postImage.image = UIImage(named: "1")
        
        self.showAlertWithEscaping(title: "Success!", message: "Item successfully posted.") {
            [unowned self] view in
            view.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension PostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            postImage.image = image
            imageSelected = true
        } else {
            print("MARK: A valid image wasn't selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
