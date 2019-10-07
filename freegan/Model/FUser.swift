//
//  User.swift
//  freegan
//
//  Created by Hammed opejin on 1/9/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import Firebase


class FUser {
    var objectId: String
    var pushId: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var email: String
    var userName: String
    var userImgUrl: String?
    
    var status: String?
    var latitude: Double?
    var longitude: Double?
   
    var blockedUsersList: [String] = [""]
    var loginMethod: String
    
    //MARK: Initializers
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _username: String, _userimgurl: String?, _loginMethod: String) {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        email = _email
        userName = _username
        userImgUrl = _userimgurl
        status = ""
        blockedUsersList.append("placeHolder")
        loginMethod = _loginMethod
    }
    
    init() {
        objectId = ""
        pushId = ""
        createdAt = nil
        updatedAt = nil
        email = ""
        userName = ""
        userImgUrl = ""
        status = ""
        blockedUsersList = [""]
        loginMethod = ""
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        createdAt = dateFormatter().date(from: _dictionary[kCREATEDAT] as! String)
        updatedAt = dateFormatter().date(from:_dictionary[kUPDATEDAT] as! String)
        
        email = _dictionary[kEMAIL] as! String
        userName = _dictionary[kUSERNAME] as! String
        userImgUrl = _dictionary[kAVATAR] as? String
        
        latitude = _dictionary[kLATITUDE] as? Double
        longitude = _dictionary[kLONGITUDE] as? Double
        
        status = _dictionary[kSTATUS] as? String
        
        if let blockedUserList = _dictionary[kBLOCKEDUSERSLIST] {
            
            blockedUsersList = blockedUserList as! [String]
            
        } else {
            
            blockedUsersList.append("placeHolder")
        }
        
        loginMethod = _dictionary[kLOGINMETHOD] as! String
    }
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, firuseruid: String, userName: String) {
        let fuser = FUser.init(_objectId: firuseruid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: email, _username: userName, _userimgurl: "", _loginMethod: kEMAIL)
        fuser.saveUserInBackground(fuser: fuser)
    }
    
    //MARK: Returning current id
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    //MARK: Save user funcs
    func saveUserInBackground(fuser: FUser, completion: @escaping (_ error: Error?) -> Void) {
        
        let ref = firebase.child(kUSER).child(fuser.objectId)
        
        ref.setValue(userDictionaryFrom(user: fuser)) { (error, ref) -> Void in
            completion(error)
        }
    }
    
    func saveUserInBackground(fuser: FUser) {
        let ref = firebase.child(kUSER).child(fuser.objectId)
        ref.setValue(userDictionaryFrom(user: fuser))
    }
    
    //MARK: Fetch User funcs
    class func fetchUser(userId: String) -> FUser? {
        var user : NSDictionary = NSDictionary()
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
            snapshot in
            
            if snapshot.exists() {
                user = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
            } else {
                user = NSDictionary()
            }
        })
        return FUser.init(_dictionary: user) as FUser
    }
    
    //MARK: Helper funcs
    func userDictionaryFrom(user: FUser) -> NSDictionary {
        
        let createdAt = dateFormatter().string(from: user.createdAt ?? Date())
        let updatedAt = dateFormatter().string(from: user.updatedAt ?? Date())
        
        return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.userName, user.userImgUrl!], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kUSERNAME as NSCopying, kAVATAR as NSCopying])
        
    }
    
    func cleanupFirebaseObservers() {
        
        firebase.child(kUSER).removeAllObservers()
        firebase.child(kRECENT).removeAllObservers()
    }
   
}
