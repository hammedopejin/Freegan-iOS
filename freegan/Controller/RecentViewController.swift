//
//  RecentViewController.swift
//  freegan
//
//  Created by Hammed opejin on 4/6/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class RecentViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []
    var firstLoad: Bool?
    var currentUser: FUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observeSingleEvent(of: .value, with: {
            [unowned self] snapshot in

            if snapshot.exists() {
                self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                self.loadRecents()
            }
            
        })
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(RecentViewController.backAction))
        
    }
    
    @objc func backAction() {
        tabBarController?.selectedIndex = 0
    }
    
    func loadPost(postId: String, post: @escaping(_ post: Post) -> Void){
        
        DataService.ds.REF_POSTS.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let currentPost = Post(postId: snapshot.key, postData: snapshot.value as! Dictionary<String, AnyObject>)
                post(currentPost)
            }
        })
    }
    
    func loadRecents() {
        
        firebase.child(kRECENT).queryOrdered(byChild: kUSERID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)).observe(.value, with: {
            [unowned self] snapshot in
            
            self.recents.removeAll()
            
            if snapshot.exists() {
                
                let sorted = ((snapshot.value as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])
                
                for recent in sorted {
                    
                    let currentRecent = recent as! NSDictionary
                    
                    if !((currentRecent[kLASTMESSAGE] as? String)!.isEmpty) {
                        self.recents.append(currentRecent)
                    }
                    
                    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: currentRecent[kCHATROOMID]).observeSingleEvent(of: .value, with: {
                        snapshot in
                    })
                }
            }
            self.tableView.reloadData()
        })
    }
}

//MARK: UITableviewDataSource
extension RecentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recents.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecentTableViewCell
        
        let recent = recents[indexPath.row]
        
        cell.bindData(recent: recent)
        
        return cell
    }
}

//MARK: UITableview Delegate
extension RecentViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let recent = recents[indexPath.row]
        recents.remove(at: indexPath.row)
        deleteRecentItem(recentID: (recent[kRECENTID] as? String)!, vc: self)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = recents[indexPath.row]
        let postId = (recent[kPOSTID] as? String)!
        let withUserUserId = (recent[kWITHUSERUSERID] as? String)!
        let chatRoomId = (recent[kCHATROOMID] as? String)!
        restartRecentChat(recent: recent, postId: postId)
        
        loadWithUser(withUserUserId: withUserUserId) { [unowned self] withUser in
            
            self.loadPost(postId: postId){ (post) in
                
                let chatVC = ChatViewController()
                chatVC.withUserUserId = withUser.objectId
                chatVC.currentUser = self.currentUser
                chatVC.post = post
                chatVC.chatRoomId = chatRoomId
                
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
        
    }
}
