//
//  OutgoingMessage.swift
//  freegan
//
//  Created by Hammed opejin on 3/23/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class OutgoingMessage {
    let ref = firebase.child(kMESSAGE)
    let messageDictionary: NSMutableDictionary
    
    init (message: String, senderId: String, senderName: String, date: Date, status: String, type: String, receiverId: String,
          postId: String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatterWithTime().string(from: date), status, type, receiverId, postId], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying, kRECEIVERID as NSCopying, kPOSTID as NSCopying])
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary, vc: UIViewController) {
        
        let reference = ref.child(chatRoomID).childByAutoId()
        item[kMESSAGEID] = reference.key
        item[kCHATROOMID] = chatRoomID
        
        reference.setValue(item) { (error, ref) in
            if error != nil {
                vc.showError(title: "Error sending message!", message: "Outgoing message error: \(String(describing: error?.localizedDescription))")
            }
        }
        updateRecents(chatRoomId: chatRoomID, lastMessage: (item[kMESSAGE] as? String)!)
        
        //send push notification
        //        let decryptedString = DecryptText(chatRoomID: chatRoomID, string: (item[kMESSAGES] as? String)!)
        //sendPushNotification1(chatRoomID: chatRoomID, message: decryptedString)
    }
}
