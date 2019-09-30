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
    var forSelf: Bool!
    var fromProfileFlag: Bool!
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
            if post.postUserObjectId == currentUser?.objectId {
                let editPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as! EditPostVC
                editPostVC.post = post
                present(editPostVC, animated: true, completion: nil)
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
    
    func showUserOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let report = UIAlertAction(title: "Report User", style: .default){ (alert: UIAlertAction!) in
            
        }
        
        let block = UIAlertAction(title: "Block User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.append(self.currentUser!.objectId)
        }
        
        let unBlock = UIAlertAction(title: "Unblock User", style: .default) { [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.remove(at: self.blockedUsersList.index(of:self.currentUser!.objectId)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(report)
        
        if (blockedUsersList.contains(currentUser!.objectId)) {
            optionMenu.addAction(unBlock)
        } else {
            optionMenu.addAction(block)
        }
        
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
}
