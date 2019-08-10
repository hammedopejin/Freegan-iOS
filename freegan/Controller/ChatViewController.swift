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
    
    var members: [String] = []
    var withUser: FUser!
    var currentUser: FUser?
    var post : Post?
    var withUserImage : UIImage?
    //var blockedUsersList: [String] = []
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    var showAvatars = false
    var firstLoad: Bool?
    
    var outgoingBubble: JSQMessagesBubbleImage?
    var incomingBubble: JSQMessagesBubbleImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID)
            .queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observe(.value, with: {
            [unowned self] snapshot in
            
            if snapshot.exists() {
                self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                self.senderDisplayName = self.currentUser?.userName
            }
        })
        
        title = post?.description
        
        senderId = (KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!)
        
        loadImage(imageUrl: (withUser?.userImgUrl)!){ [unowned self] (image) in
            self.withUserImage = image
            self.loadMessegas()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ChatViewController.backAction))
        
        loadImage(imageUrl: (post?.imageUrl[0])!){ [unowned self] (image) in
            let postImageButton  = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(ChatViewController.seeProfile))
            postImageButton.setBackgroundImage(resizeImage(image: image, targetSize: CGSize(width: 100.0, height: 40.0)), for: .normal, barMetrics: .default)
            
            let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_settings_white_24dp"), style: .plain, target: self, action: #selector(ChatViewController.showUserOptions))
            
            self.navigationItem.rightBarButtonItems = [settingsButton, postImageButton]
        }
        
        self.loadWithUser(withUserUserId: withUser.objectId) {(withUser) in
            self.withUser = withUser
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
    }
    
    //JSQMessages Data Source functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == currentUser!.objectId {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    
        let message = messages[indexPath.row]
        var avatar: JSQMessageAvatarImageDataSource
    
        if message.senderId != currentUser!.objectId {
            if let withUserAvatar = withUserImage {
                avatar = JSQMessagesAvatarImageFactory.avatarImage(with: withUserAvatar, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ic_account_circle_black_24dp"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
        } else {
            return nil
        }
        
        return avatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    
        if messages[indexPath.item].senderId == senderId {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if outgoing(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            sendMessage(text: text, date: date)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        loadMore(maxNumber: max, minNumber: min)
        collectionView!.reloadData()
    }
    
    //MARK:  UITextViewDelegate
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        typingIndicatorStart()
        return true
    }
    
    @objc func backAction() {
        clearRecentCounter(chatRoomID: chatRoomId)
        chatRef.child(chatRoomId).removeAllObservers()
        typingRef.child(chatRoomId).removeAllObservers()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func seeProfile(_ sender: Any) {
        var poster: FUser?
        if post?.postUserObjectId == currentUser?.objectId {
            poster = currentUser
        } else {
            poster = withUser
        }
        
        guard let _ = poster else {
            return
        }
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")  as! ProfileVC
        profileVC.poster = poster
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func showUserOptions(){
        var blockedUsersList = self.withUser.blockedUsersList
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let report = UIAlertAction(title: "Report User", style: .default){ (alert: UIAlertAction!) in
            
        }
        
        let block = UIAlertAction(title: "Block User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            
            blockedUsersList.append(self.currentUser!.objectId)
            firebase.child(kUSER).child(self.withUser.objectId).updateChildValues([kBLOCKEDUSERSLIST : blockedUsersList]) { [unowned self] (_,_) in
                
            }
        }
        
        let unBlock = UIAlertAction(title: "Unblock User", style: .default) { [unowned self] (alert: UIAlertAction!) in
            
            firebase.child(kUSER).child(self.withUser.objectId).child(kBLOCKEDUSERSLIST).child("\(blockedUsersList.index(of: self.currentUser!.objectId)!)").removeValue() { [unowned self] (_,_) in
                blockedUsersList.remove(at: blockedUsersList.index(of:self.currentUser!.objectId)!)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(report)
        
        if (withUser.blockedUsersList.contains(currentUser!.objectId)) {
            optionMenu.addAction(unBlock)
        } else {
            optionMenu.addAction(block)
        }
        
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func loadWithUser(withUserUserId: String, withUser: @escaping(_ withUser: FUser) -> Void){
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: withUserUserId)
            .observe(.value, with: {
                snapshot in
                
                if snapshot.exists() {
                    
                    let poster = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    withUser(poster)
                }
                
            })
    }
    
    func sendMessage(text: String?, date: Date) {
        
        var outgoingMessage: OutgoingMessage?
        
        //text message
        if let text = text {
            let encryptedText = text
//            let encryptedText = EncryptText(chatRoomID: chatRoomId, string: text)
            
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: currentUser!.objectId, senderName: currentUser!.userName, date: date, status: kDELIVERED, type: kTEXT, receiverId: (withUser?.objectId)!, postId: (post?.postId)!)
        }
        finishSendingMessage()
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary, vc: self)
    }

    
    func loadMessegas() {
        //createTypingObservers()
        
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        chatRef.child(chatRoomId).observe(.childAdded, with: {
            [unowned self] snapshot in
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
            [unowned self] snapshot in
            self.updateMessage(item: snapshot.value as! NSDictionary)
        })
        
        chatRef.child(chatRoomId).observeSingleEvent(of: .value, with: {
            [unowned self] snapshot in
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
                collectionView!.reloadData()
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
            insertMessage(item: item)
            loadCount += 1
        }
        
        showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    
    func loadMore(maxNumber: Int, minNumber: Int) {
        
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            min = 0
        }
        for i in (min ... max).reversed() {
            let item = loaded[i]
            insertNewMessage(item: item)
            loadCount += 1
        }
        showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    func insertNewMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: collectionView!)
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.insert(item, at: 0)
        messages.insert(message!, at: 0)
        
        return incoming(item: item)
    }
    
    
    func insertMessage(item: NSDictionary) -> Bool {
        if ((item[kSENDERID] as! String) != KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!) {
            updateChatStatus(chat: item, chatRoomId: chatRoomId)
        }
        let incomingMessage = IncomingMessage(collectionView_: collectionView!)
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item: item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if currentUser!.objectId == item[kSENDERID] as! String {
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
    
    //MARK: Typing indicator
    func createTypingObservers() {
        
        typingRef.child(chatRoomId).observe(.childChanged, with: {
            [unowned self] snapshot in
            
            if snapshot.key != FUser.currentId() {
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
        
        perform(#selector(ChatViewController.typingIndicatorStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingIndicatorStop() {
        
        typingCounter -= 1
        if typingCounter == 0 {
            typingIndicatorSave(typing: false)
        }
    }
    
    func typingIndicatorSave(typing: Bool) {
        typingRef.child(chatRoomId).updateChildValues([FUser.currentId() : typing])
    }
    
}
