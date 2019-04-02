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
       
        guard let img = postImage.image, imageSelected == true else {
            showToast(message: "An image must be selected!")
            return
        }
        guard let description = postDescription.text, description != "" else {
            showToast(message: "Item must have description!")
            return
        }

        if let imgData = img.jpegData(compressionQuality: 0.2) {

            let imgUid = NSUUID().uuidString

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            let ref = DataService.ds.REF_POST_IMAGES.child(imgUid)

            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = ref.putData(imgData, metadata: metadata) { (metadata, error) in
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
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    static var useCamera = false
    var cam: Camera?
    var currentUser: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        if PostVC.useCamera{
            cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: imagePicker)
        } else {
            cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: imagePicker)
        }
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
    
    func postToFirebase(imgUrl: String) {
        let date = Date()
        let result = dateFormatterWithTime().string(from: date)

        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        let postId: String = firebasePost.key!

        let post: Dictionary<String, AnyObject> = [
            kPOSTID : postId as AnyObject,
            kDESCRIPTION : postDescription.text! as AnyObject,
            kIMAGEURL : [imgUrl] as AnyObject,
            kPROFILEIMAGEURL : currentUser!.userImgUrl as AnyObject,
            kUSERNAME : self.currentUser!.userName as AnyObject,
            kPOSTDATE : result as AnyObject,
            kPOSTUSEROBJECTID : currentUser!.objectId as AnyObject
        ]

        firebasePost.setValue(post)

        postDescription.text = ""
        imageSelected = false
        postImage.image = UIImage(named: "1")

        self.navigationController?.popViewController(animated: true)
    }
    
}
