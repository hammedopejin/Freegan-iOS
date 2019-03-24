//
//  OutgoingMessage.swift
//  freegan
//
//  Created by Hammed opejin on 3/23/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation

class OutgoingMessage {
    let ref = firebase.child(kMESSAGE)
    let messageDictionary: NSMutableDictionary
    
    init (message: String, senderId: String, senderName: String, date: Date, status: String, type: String, receiverId: String,
          postId: String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatterWithTime().string(from: date), status, type,
                                                          receiverId, postId], forKeys: [kMESSAGES as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying, kRECEIVERID as NSCopying, kPOSTID as NSCopying])
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary) {
        
        let reference = ref.child(chatRoomID).childByAutoId()
        item[kMESSAGEID] = reference.key
        item[kCHATROOMID] = chatRoomID
        
        reference.setValue(item) { (error, ref) in
            if error != nil {
                
                //ProgressHUD.showError("Outgoing message error: \(error?.localizedDescription)")
            }
        }
        updateRecents(chatRoomId: chatRoomID, lastMessage: (item[kMESSAGES] as? String)!)
        
        //send push notification
        //        let decryptedString = DecryptText(chatRoomID: chatRoomID, string: (item[kMESSAGES] as? String)!)
        //sendPushNotification1(chatRoomID: chatRoomID, message: decryptedString)
    }
}
