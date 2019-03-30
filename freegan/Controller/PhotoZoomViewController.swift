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
    
    @IBAction func startChat(_ sender: Any) {
        let chatVC = ChatViewController()
        
        chatVC.titleName = self.poster!.userName
        chatVC.withUserId = self.post!.postUserObjectId
        if ((self.currentUser) != nil) {
            chatVC.chatRoomId = freegan.startChat(user1: self.currentUser!, user2: self.poster!, postId: self.post!.postId)
            chatVC.hidesBottomBarWhenPushed = true
            if (self.currentUser!.objectId != self.poster!.objectId){
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
    
    var postImage: UIImage!
    var posterImage: UIImage!
    var post: Post?
    var poster: User?
    var currentUser: User?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postImageView.image = self.postImage
        self.posterImageView.image = self.posterImage
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

}
