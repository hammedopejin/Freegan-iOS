//
//  PhotoZoomViewController.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var posterImageView: CircleView!
    @IBOutlet weak var postDescription: UITextField!
    @IBOutlet weak var chatButtonImage: CircleView!
    
    
    var postImage: UIImage!
    var posterImage: UIImage!
    var post: Post?
    var poster: FUser?
    var currentUser: FUser?
    var index: Int = 0
    var forSelf = false
    var fromProfileFlag = false
    var fromChatFlag = false
    var blockedUsersList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = postImage
        
        if (forSelf || fromProfileFlag){
            posterImageView.image = UIImage(named: "ic_settings_white_24dp")
        } else {
            posterImageView.image = posterImage
        }
        
        postDescription.text = post!.description
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = poster {
            if (fromProfileFlag) {
                firebase.child(kUSER).child(poster!.objectId).updateChildValues([kBLOCKEDUSERSLIST : blockedUsersList])
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!fromChatFlag) {
            blockedUsersList = poster!.blockedUsersList
            return
        }
        self.loadWithUser(withUserUserId: poster!.objectId) { (poster) in
            self.poster = poster
            self.blockedUsersList = poster.blockedUsersList
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        if (currentUser!.objectId == poster!.objectId){
            chatButtonImage.isHidden = true
        }
    }
    
    @IBAction func startChat(_ sender: Any) {
        
        let chatVC = ChatViewController()
        
        if (currentUser!.objectId != poster!.objectId){
            firebase.child(kUSER).child(poster!.objectId).updateChildValues([kBLOCKEDUSERSLIST : blockedUsersList])
            fromChatFlag = true
            chatVC.withUserUserId = poster!.objectId
            chatVC.currentUser = currentUser
            chatVC.post = post
            chatVC.chatRoomId = freegan.startChat(user1: currentUser!, user2: poster!, postId: post!.postId)
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    @IBAction func seeProfile(_ sender: Any) {
        
        if (forSelf || fromProfileFlag) {
            
            guard let post = post else {
                return
            }
            
            if (fromProfileFlag && !forSelf) {
                showUserOptions()
                return
            }
            
            if post.postUserObjectId == currentUser!.objectId {
                showDeleteOrEditOptions(post.postId)
            }
            
        } else {
            guard let poster = poster else {
                return
            }
            
            let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")  as! ProfileVC
            profileVC.posterUserId = poster.objectId
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
    func showDeleteOrEditOptions(_ postId: String) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let editPostAction = UIAlertAction(title: "Edit Post", style: .default) { [unowned self] (alert: UIAlertAction!) in
            let editPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as! EditPostVC
            editPostVC.post = self.post
            self.present(editPostVC, animated: true, completion: nil)
        }
        
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { [unowned self] (alert: UIAlertAction!) in
            self.deletePostAlert(postId: postId)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(editPostAction)
        optionMenu.addAction(deletePostAction)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func showUserOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let reportUserAction = UIAlertAction(title: "Report User", style: .default){ (alert: UIAlertAction!) in
            
        }
        
        let blockUserAction = UIAlertAction(title: "Block User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.append(self.currentUser!.objectId)
        }
        
        let unBlockUserAction = UIAlertAction(title: "Unblock User", style: .default) { [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.remove(at: self.blockedUsersList.index(of:self.currentUser!.objectId)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        optionMenu.addAction(reportUserAction)
        
        if (blockedUsersList.contains(currentUser!.objectId)) {
            optionMenu.addAction(unBlockUserAction)
        } else {
            optionMenu.addAction(blockUserAction)
        }
        
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func deletePostAlert(postId: String) {
        
        let deleteAlert = UIAlertController(title: "ATTENTION!!!", message: "Are you sure you want to delete?", preferredStyle: .alert)
        
        let deleteAction =  UIAlertAction(title: "Delete Post", style: .destructive){ [unowned self] (alert: UIAlertAction!) in
            self.deletePost(postId: postId)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
    
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func deletePost(postId: String) {
        
        firebase.child(kPOST).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                
                self.showSpinner(onView: self.view)
                
                let postData = snapshot.value as! Dictionary<String, AnyObject>
     
                let post = Post(postId: postData.keys.first!, postData: postData)
                
                for i in post.imageUrl {
                    let toDelete = storage.reference(forURL: i)
                    toDelete.delete(completion: nil)
                }
                firebase.child(kPOST).child(postId).removeValue()
                firebase.child(kPOSTLOCATION).child(postId).removeValue()
                
                firebase.child(kRECENT).queryOrdered(byChild: kPOSTID).queryEqual(toValue: postId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.exists() {
                        let recents = snapshot.value as! Dictionary<String, AnyObject>
                        
                        for i in recents.keys {
                            firebase.child(kRECENT).child(i).removeValue()
                        }
                        self.removeSpinner()
                        self.showAlertWithEscaping(title: "Success!", message: "Post item deleted") {
                            view in
                            view.dismiss(animated: true, completion: nil)
                            self.parent?.parent?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self.removeSpinner()
                        self.showAlertWithEscaping(title: "Success!", message: "Post item deleted") {
                            view in
                            view.dismiss(animated: true, completion: nil)
                            self.parent?.parent?.navigationController?.popViewController(animated: true)
                        }
                    }
                })
  
            }
        })
        
    }
    
}
