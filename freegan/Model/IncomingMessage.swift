//
//  IncomingMessage.swift
//  freegan
//
//  Created by Hammed opejin on 3/23/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import SwiftKeychainWrapper

public class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary[kTYPE] as? String
        
        if type == kTEXT {
            message = createTextMessage(item: dictionary, chatRoomId: chatRoomID)
        }
        
        if message != nil {
            return message
        }
        return nil
    }
    
    func createTextMessage(item: NSDictionary, chatRoomId: String) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatterWithTime().date(from: (item[kDATE] as? String)!)
        let decryptedText =  (item[kMESSAGES] as? String)!
        
//      let decryptedText = DecryptText(chatRoomID: chatRoomId, string: (item[kMESSAGES] as? String)!)
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: decryptedText)
    }
}
