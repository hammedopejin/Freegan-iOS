//
//  ChatViewController.swift
//  freegan
//
//  Created by Hammed opejin on 3/23/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import SwiftKeychainWrapper

class ChatViewController: JSQMessagesViewController {
    
    var userName:String?
    var postKey:String?
    
    let chatRef = firebase.child(kMESSAGE)
    let typingRef = firebase.child(kTYPINGPATH)
    
    var loadCount = 0
    var typingCounter = 0
    
    var max = 0
    var min = 0
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var members: [String] = []
    var withUserId: String = ""
    var withUser: User?
    var titleName: String?
    var currentUser: User?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    var showAvatars = false
    var firstLoad: Bool?
    
    var outgoingBubble: JSQMessagesBubbleImage?
    var incomingBubble: JSQMessagesBubbleImage?
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        avatarDictionary = [ : ]
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ChatViewController.backAction))
        
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //updateUI()
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observe(.value, with: {
            snapshot in
            
            if snapshot.exists() {
                self.currentUser = User.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                self.senderDisplayName = self.currentUser?.userName
            }
        })
        self.title = self.titleName
        self.senderId = (KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!)
        loadMessegas()
    }
    
    @objc func backAction() {
        clearRecentCounter(chatRoomID: chatRoomId)
        chatRef.child(chatRoomId).removeAllObservers()
        typingRef.child(chatRoomId).removeAllObservers()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: JSQMessages Data Source functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == self.currentUser!.objectId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    
        let data = messages[indexPath.row]
        if data.senderId == self.currentUser!.objectId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        let status = message[kSTATUS] as! String
        
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if outgoing(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    //MARK: JSQMesages Delegate functions
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            sendMessage(text: text, date: date)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        loadMore(maxNumber: max, minNumber: min)
        self.collectionView!.reloadData()
    }
    
    //MARK: Send Message
    func sendMessage(text: String?, date: Date) {
        
        var outgoingMessage: OutgoingMessage?
        
        //text message
        if let text = text {
            let encryptedText = text
//            let encryptedText = EncryptText(chatRoomID: chatRoomId, string: text)
            //Needs receiverId and postId
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: self.currentUser!.objectId, senderName: self.currentUser!.userName, date: date, status: kDELIVERED, type: kTEXT, receiverId: kRECEIVERID, postId: kPOSTID)
        }
        self.finishSendingMessage()
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary)
    }
    
    
    //MARK: Load Messages
    
    func loadMessegas() {
        //createTypingObservers()
        
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        chatRef.child(chatRoomId).observe(.childAdded, with: {
            snapshot in
            //update UI
            if snapshot.exists() {
                
                let item = (snapshot.value as? NSDictionary)!
                
                if let type = item[kTYPE] as? String {
                    if legitTypes.contains(type) {
                        if self.initialLoadComplete {
                            _ = self.insertMessage(item: item)
                            self.finishReceivingMessage()
                        } else {
                            self.loaded.append(item)
                        }
                    }
                }
            }
        })
        
        chatRef.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            self.updateMessage(item: snapshot.value as! NSDictionary)
        })
        
        chatRef.child(chatRoomId).observeSingleEvent(of: .value, with: {
            snapshot in
            self.insertMessages()
            self.finishReceivingMessage(animated: false)
            self.initialLoadComplete = true
        })
    }
    
    func updateMessage(item: NSDictionary) {
        for index in 0 ..< objects.count {
            let temp = objects[index]
            if item[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objects[index] = item
                self.collectionView!.reloadData()
            }
        }
    }
    
    func insertMessages() {
        max = loaded.count - loadCount
        min = max - kNUMBEROFMESSAGES
        if min < 0 {
            min = 0
        }
        for i in min ..< max {
            let item = loaded[i]
            self.insertMessage(item: item)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    
    func loadMore(maxNumber: Int, minNumber: Int) {
        
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            min = 0
        }
        for i in (min ... max).reversed() {
            let item = loaded[i]
            self.insertNewMessage(item: item)
            loadCount += 1
        }
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    func insertNewMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.insert(item, at: 0)
        messages.insert(message!, at: 0)
        
        return incoming(item: item)
    }
    
    
    func insertMessage(item: NSDictionary) -> Bool {
        if ((item[kSENDERID] as! String) != KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!) {
            updateChatStatus(chat: item, chatRoomId: chatRoomId)
        }
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item: item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if self.currentUser!.objectId == item[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if ((KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!) == item[kSENDERID] as! String) {
            return true
        } else {
            return false
        }
    }

    func updateUI() {
        getWithUserFromRecent(member: withUserId) { (withUser) in
            self.withUser = withUser
        }
    }
    
    func getWithUserFromRecent(member: String, result: @escaping (_ withUser: User) -> Void) {
        
        var receivedMember: User?
            
            if withUserId != KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
                
                firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: withUserId).observe(.value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        
                        let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                        
                        let cUser = User.init(_dictionary: userDictionary as! NSDictionary)
                        
                        receivedMember = cUser
                        
                        if receivedMember != nil {
                            result(receivedMember!)
                        }
                    }
                })
            }
    }
    
    //MARK: Typing indicator
    func createTypingObservers() {
        
        typingRef.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            if snapshot.key != User.currentId() {
                let typing = snapshot.value as! Bool
                self.showTypingIndicator = typing
                if typing {
                    self.scrollToBottom(animated: true)
                }
            }
        })
    }
    
    func typingIndicatorStart() {
        
        typingCounter += 1
        typingIndicatorSave(typing: true)
        
        self.perform(#selector(ChatViewController.typingIndicatorStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingIndicatorStop() {
        
        typingCounter -= 1
        if typingCounter == 0 {
            typingIndicatorSave(typing: false)
        }
    }
    
    func typingIndicatorSave(typing: Bool) {
        typingRef.child(chatRoomId).updateChildValues([User.currentId() : typing])
    }
    
    //MARK:  UITextViewDelegate
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        typingIndicatorStart()
        return true
    }
}
