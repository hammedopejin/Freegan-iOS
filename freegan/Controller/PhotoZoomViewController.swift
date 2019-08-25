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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = postImage
        
        if(forSelf){
            posterImageView.image = UIImage(named: "ic_settings_white_24dp")
        } else {
            posterImageView.image = posterImage
        }
        
        postDescription.text = post!.description
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
            
            chatVC.withUserUserId = poster!.objectId
            chatVC.currentUser = currentUser
            chatVC.post = post
            chatVC.chatRoomId = freegan.startChat(user1: currentUser!, user2: poster!, postId: post!.postId)
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    @IBAction func seeProfile(_ sender: Any) {
        
        if(forSelf) {
            guard let post = post else {
                return
            }
            
            if post.postUserObjectId == currentUser?.objectId {
                let editPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as! EditPostVC
                editPostVC.post = post
                present(editPostVC, animated: true, completion: nil)
            } else {
                
            }
            
        } else {
            guard let poster = poster else {
                return
            }
            
            let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")  as! ProfileVC
            profileVC.poster = poster
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
}
