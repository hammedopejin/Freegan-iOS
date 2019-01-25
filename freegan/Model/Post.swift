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
    private var _caption: String!
    private var _imageUrl: String!
    private var _profileImgUrl: String!
    private var _userName: String!
    private var _postUserObjectId: String!
    private var _postKey: String!
    private var _postDate: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
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
    
    var postKey: String {
        return _postKey
    }
    
    var postDate: String {
        return _postDate
    }
    
    init(postKey: String, caption: String, imageUrl: String, postDate: String, profileImgUrl: String, userName: String, postUserObjectId: String) {
        self._postKey = postKey
        self._caption = caption
        self._imageUrl = imageUrl
        self._postDate = postDate
        self._profileImgUrl = profileImgUrl
        self._userName = userName
        self._postUserObjectId = postUserObjectId
        
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["description"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
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
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
        
    }

}
