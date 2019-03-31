//
//  User.swift
//  freegan
//
//  Created by Hammed opejin on 1/9/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import Firebase


class User {
    var objectId: String
    var pushId: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var email: String
    var userName: String
    var userImgUrl: String
    
    var status: String = ""
    var latitude: Double?
    var longitude: Double?
   
    var blockedUsersList: [String] = [""]
    var loginMethod: String
    
    //MARK: Initializers
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _username: String, _userimgurl: String = "", _loginMethod: String) {
        
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
        loginMethod = ""
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        createdAt = dateFormatter().date(from: _dictionary[kCREATEDAT] as! String)
        updatedAt = dateFormatter().date(from:_dictionary[kUPDATEDAT] as! String)
        
        email = _dictionary[kEMAIL] as! String
        userName = _dictionary[kUSERNAME] as! String
        userImgUrl = _dictionary[kAVATAR] as! String
        
        latitude = _dictionary[kLATITUDE] as? Double
        longitude = _dictionary[kLONGITUDE] as? Double
        
        if let blockedUserList = _dictionary[kBLOCKEDUSERS] {
            
            blockedUsersList = blockedUserList as! [String]
            
        } else {
            
            blockedUsersList.append("placeHolder")
        }
        
        
        loginMethod = _dictionary[kLOGINMETHOD] as! String
        
    }
    
    
    //MARK: Returning current user funcs
    
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    //    class func currentUser () -> User? {
    //
    //        if Auth.auth().currentUser != nil {
    //
    //            let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER)
    //
    //            return User.init(_dictionary: dictionary as! NSDictionary)
    //        }
    //
    //        return nil
    //
    //    }
    
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, firuseruid: String, userName: String) {
        let fuser = User.init(_objectId: firuseruid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: email, _username: userName, _userimgurl: "", _loginMethod: kEMAIL)
        fuser.saveUserLocally(fuser: fuser)
        fuser.saveUserInBackground(fuser: fuser)
 
    }
    
    
    //MARK: Save user funcs
    func saveUserInBackground(fuser: User, completion: @escaping (_ error: Error?) -> Void) {
        
        let ref = firebase.child(kUSER).child(fuser.objectId)
        
        ref.setValue(userDictionaryFrom(user: fuser)) { (error, ref) -> Void in
            
            completion(error)
            
        }
        
    }
    
    func saveUserInBackground(fuser: User) {
        
        let ref = firebase.child(kUSER).child(fuser.objectId)
        
        ref.setValue(userDictionaryFrom(user: fuser))
        
    }
    
    
    func saveUserLocally(fuser: User) {
        
        UserDefaults.standard.set(userDictionaryFrom(user: fuser), forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize()
        
    }
    
    
    //MARK: Fetch User funcs
    
    
    class func fetchUser(userId: String) -> User? {
        var user : NSDictionary = NSDictionary()
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
            snapshot in
            
            if snapshot.exists() {
                
                user = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
                
            } else {
                
                user = NSDictionary()
                
            }
            
        })
        return User.init(_dictionary: user) as User
        
    }
    
    
    //MARK: Helper funcs
    
    func userDictionaryFrom(user: User) -> NSDictionary {
        
        let createdAt = dateFormatter().string(from: user.createdAt ?? Date())
        let updatedAt = dateFormatter().string(from: user.updatedAt ?? Date())
        
        return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.userName, user.userImgUrl], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kUSERNAME as NSCopying, kAVATAR as NSCopying])
        
    }
    
    func cleanupFirebaseObservers() {
        
        firebase.child(kUSER).removeAllObservers()
        firebase.child(kRECENT).removeAllObservers()
    }
    
    
    //MARK: Update current user funcs
    
    //func updateUser(withValues : [String : Any], withBlock: @escaping (_ success: Bool) -> Void) {
    //
    //
    //    let currentUser = User.currentUser()!
    //
    //    let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
    //
    //    userObject.setValuesForKeys(withValues)
    //
    //    let ref = firebase.child(kUSER).child(User.currentId())
    //
    //    ref.updateChildValues(withValues, withCompletionBlock: {
    //        error, ref in
    //
    //        if error != nil {
    //            print("couldnt update user \(String(describing: error?.localizedDescription))")
    //            withBlock(false)
    //            return
    //        }
    //
    //        //update current user
    //        userDefaults.setValue(userObject, forKeyPath: kCURRENTUSER)
    //        userDefaults.synchronize()
    //
    //        withBlock(true)
    //
    //    })
    //}
   
}
