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
        
        self.postImageView.image = self.postImage
        
        if(forSelf){
            self.posterImageView.image = UIImage(named: "ic_settings_white_24dp")
        } else {
            self.posterImageView.image = self.posterImage
        }
        
        postDescription.text = post!.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        if (self.currentUser!.objectId == self.poster!.objectId){
            self.chatButtonImage.isHidden = true
        }
    }
    
    @IBAction func startChat(_ sender: Any) {
        let chatVC = ChatViewController()
        
        if (self.currentUser!.objectId != self.poster!.objectId){
            
            chatVC.withUser = self.poster
            chatVC.currentUser = self.currentUser
            chatVC.post = self.post
            chatVC.chatRoomId = freegan.startChat(user1: self.currentUser!, user2: self.poster!, postId: self.post!.postId)
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    @IBAction func seeProfile(_ sender: Any) {
        
        if(forSelf){
            guard let post = self.post else{
                return
            }
            
            if post.postUserObjectId == currentUser?.objectId{
                let editPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as! EditPostVC
                editPostVC.post = post
                
                self.present(editPostVC, animated: true, completion: nil)
            } else {
                
            }
            
        } else {
            guard let poster = self.poster else {
                return
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseVC") as! UITabBarController
            
            let profileVC = vc.viewControllers![2].children[0] as! ProfileVC
            profileVC.poster = poster
            profileVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.present(vc, animated: false, completion: nil)
            vc.selectedIndex = 2
        }
        
    }
    
}
