//
//  Post.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _description: String!
    private var _imageUrl: [String]!
    private var _profileImgUrl: String!
    private var _userName: String!
    private var _postUserObjectId: String!
    private var _postId: String!
    private var _postDate: String!
    private var _postRef: DatabaseReference!
    
    var description: String {
        return _description
    }
    
    var imageUrl: [String] {
        return _imageUrl
    }
    
    var profileImgUrl: String {
        return _profileImgUrl
    }
    
    var userName: String {
        return _userName
    }
    
    var postUserObjectId: String {
        return _postUserObjectId
    }
    
    var postId: String {
        return _postId
    }
    
    var postDate: String {
        return _postDate
    }
    
    init(postId: String, description: String, imageUrl: [String], postDate: String, profileImgUrl: String, userName: String, postUserObjectId: String) {
        self._postId = postId
        self._description = description
        self._imageUrl = imageUrl
        self._postDate = postDate
        self._profileImgUrl = profileImgUrl
        self._userName = userName
        self._postUserObjectId = postUserObjectId
        
    }
    
    init(postId: String, postData: Dictionary<String, AnyObject>) {
        self._postId = postId
        
        if let description = postData["description"] as? String {
            self._description = description
        }
        
        if let imageUrl = postData["imageUrl"] as? [String] {
            self._imageUrl = imageUrl
        }
        
        if let profileImgUrl = postData["profileImgUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        if let userName = postData["userName"] as? String {
            self._userName = userName
        }
        
        if let postUserObjectId = postData["postUserObjectId"] as? String {
            self._postUserObjectId = postUserObjectId
        }
        
        if let postDate = postData["postDate"] as? String {
            self._postDate = postDate
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postId)
        
    }
}
