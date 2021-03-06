//
//  Recent.swift
//  freegan
//
//  Created by Hammed opejin on 3/23/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper


func startChat(user1: FUser, user2: FUser, postId: String) -> String {
    
    let userId1 = user1.objectId as String
    let userId2 = user2.objectId as String
    
    var chatRoomId: String = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2 + postId
        
    } else {
        chatRoomId = userId2 + userId1 + postId
    }
    
    let members = [userId1, userId2]
    
    createRecent(userId: userId1, chatRoomId: chatRoomId, members: members, postId: postId, withUserUserId: userId2, withUserUsername: user2.userName, type: kPRIVATE)
    createRecent(userId: userId2, chatRoomId: chatRoomId, members: members, postId: postId, withUserUserId: userId1, withUserUsername: user1.userName, type: kPRIVATE)
    
    
    return chatRoomId
}


func createRecent(userId: String, chatRoomId: String, members: [String], postId: String, withUserUserId: String, withUserUsername: String, type: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        var create = true
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                if currentRecent[kUSERID] as! String == userId {
                    
                    create = false
                    
                }
                firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: currentRecent[kCHATROOMID]).observe(.value, with: {
                    snapshot in
                    
                })
            }
        }
        
        if create && userId != withUserUserId {
            
            creatRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, postId: postId, withUserUserId: withUserUserId, withUserUsername: withUserUsername, type: type)
        }
        
        
    })
    
}

func creatRecentItem(userId: String, chatRoomId: String, members: [String], postId: String,
                     withUserUserId: String, withUserUsername: String, type: String) {
    
    let refernce = firebase.child(kRECENT).childByAutoId()
    
    let recentId = refernce.key
    let date = dateFormatterWithTime().string(from: Date())
    
    
    let recent = [kRECENTID: recentId!, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kPOSTID: postId, kWITHUSERUSERNAME: withUserUsername, kWITHUSERUSERID: withUserUserId, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: type] as [String : Any]
    
    refernce.setValue(recent) { (error, ref) in
        
        if error != nil {
        }
    }
}

func restartRecentChat(recent: NSDictionary, postId: String) {
    
    var currentUser: FUser?
    
    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observe(.value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
            
            if (recent[kTYPE] as? String)! == kPRIVATE {
                
                for userId in recent[kMEMBERS] as! [String] {
                    
                    if (userId != KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!) {
                        
                        createRecent(userId: userId, chatRoomId: (recent[kCHATROOMID] as? String)!, members: recent[kMEMBERS] as! [String], postId: postId, withUserUserId: currentUser!.objectId, withUserUsername: currentUser!.userName, type: kPRIVATE)
                    }
                }
            }
        }
    })
}


func updateRecents(chatRoomId: String, lastMessage: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                updateRecentItem(recent: recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
        
    })
    
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatterWithTime().string(from: Date())
    
    var counter = recent[kCOUNTER] as! Int
    
    if ((recent[kUSERID] as? String != KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!)) {
        counter += 1
    }
    
    let values = [kLASTMESSAGE: lastMessage, kCOUNTER: counter, kDATE: date] as [String : Any]
    
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values as [NSObject : AnyObject]) {
        (error, ref) -> Void in
        
        if error != nil {
        }
        
    }
    
}

func clearRecentCounter(chatRoomID: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                if (currentRecent[kUSERID] as? String == KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!) {
                    
                    clearRecentCounterItem(recent: currentRecent)
                }
                
                
            }
        }
    })
}

func clearRecentCounterItem(recent: NSDictionary) {
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues([kCOUNTER : 0]) { (error, ref) -> Void in
        
        if error != nil {
            
        }
    }
    
}

func deleteRecentItem(recentID: String, vc: UIViewController) {
    
    firebase.child(kRECENT).child(recentID).removeValue { (error, ref) in
        
        if error != nil {
            vc.showError(title: "Error deleting recent item!", message: "Couldnt delete recent item: \(error!.localizedDescription)")
        }
    }
}

func deleteMultipleRecentItems(chatRoomID: String, vc: UIViewController) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                deleteRecentItem(recentID: (currentRecent[kRECENTID] as? String)!, vc: vc)
                
            }
            
        }
    })
    
}


func updateChatStatus(chat: NSDictionary, chatRoomId: String) {
    
    let values = [kSTATUS : kREAD]
    
    firebase.child(kMESSAGE).child(chatRoomId).child((chat[kMESSAGEID] as? String)!).updateChildValues(values)
    
}


func deleteChatroom(chatRoomID: String) {
    
    firebase.child(kMESSAGE).child(chatRoomID).removeValue { (error, ref) in
        
        if error != nil {
        }
    }
}

