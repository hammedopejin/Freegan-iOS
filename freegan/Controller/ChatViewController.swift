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
    var withUserUserId: String!
    var blockedUsersList: [String] = []
    var currentUser: FUser!
    var post : Post!
    var withUserImage : UIImage?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    var showAvatars = false
    var firstLoad: Bool?
    
    var outgoingBubble: JSQMessagesBubbleImage?
    var incomingBubble: JSQMessagesBubbleImage?
    var blockedButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        navigationController?.hidesBarsOnTap = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        firebase.child(kUSER).child(withUser.objectId).updateChildValues([kBLOCKEDUSERSLIST : blockedUsersList])
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
        //typingIndicatorStart()
        return true
    }
    
    @objc func backAction() {
        clearRecentCounter(chatRoomID: chatRoomId)
        chatRef.child(chatRoomId).removeAllObservers()
        //typingRef.child(chatRoomId).removeAllObservers()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func seeProfile(_ sender: Any) {
        var poster: FUser!
        if post?.postUserObjectId == currentUser.objectId {
            poster = currentUser
        } else {
            poster = withUser
        }
        
        guard let _ = poster else {
            return
        }
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")  as! ProfileVC
        profileVC.posterUserId = poster.objectId
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func showUserOptions(){
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        
        let report = UIAlertAction(title: "Report User", style: .default){ [unowned self](alert: UIAlertAction!) in
            let reportVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ReportUserVC")
                as! ReportUserVC
            reportVC.poster = self.withUser
            reportVC.currentUser = self.currentUser
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
        
        let block = UIAlertAction(title: "Block User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.append(self.currentUser.objectId)
            self.inputToolbar.isHidden = true
            self.view.endEditing(true)
            self.blockedButton = self.showBlockedUserMessage()
            self.view.addSubview(self.blockedButton!)
        }
        
        let unBlock = UIAlertAction(title: "Unblock User", style: .default) { [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.remove(at: self.blockedUsersList.index(of:self.currentUser!.objectId)!)
            self.inputToolbar.isHidden = false
            if let button = self.blockedButton {
                button.removeFromSuperview()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(report)
        
        if (blockedUsersList.contains(currentUser!.objectId)) {
            optionMenu.addAction(unBlock)
        } else {
            optionMenu.addAction(block)
        }
        
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func showBlockedUserMessage() -> UIButton {
        
        let buttonX = 0
        let buttonY = Int(UIScreen.main.bounds.size.height - 50)
        let buttonWidth = Int(UIScreen.main.bounds.size.width)
        let buttonHeight = 50
        
        let button = UIButton(type: .system)
        button.setTitle("   Chat blocked by participant!", for: .normal)
        button.tintColor = .lightGray
        button.backgroundColor = .white
        button.setImage(UIImage(named: "ic_block_red_400_24dp"), for: .normal)
        button.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        return button
    }
    
    func setUpChat() {
        
        inputToolbar.contentView.leftBarButtonItem = nil
        let sendButton = UIButton(frame: .zero)
        let sendImage = UIImage(named: "ic_send_grey_24dp")
        sendButton.setImage(sendImage, for: .normal)
        inputToolbar.contentView.rightBarButtonItem = sendButton
        
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID)
            .queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observeSingleEvent(of: .value, with: {
                [unowned self] snapshot in
                
                if snapshot.exists() {
                    self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    self.senderDisplayName = self.currentUser.userName
                }
            })
        
        title = post?.description
        
        senderId = (KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!)
        
        loadWithUser(withUserUserId: withUserUserId) { [unowned self] (withUser) in
            self.withUser = withUser
            self.blockedUsersList = self.withUser.blockedUsersList
            loadImage(imageUrl: (withUser.userImgUrl)!){ [unowned self] (image) in
                self.withUserImage = image
                self.loadMessegas()
            }
            
            firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: self.withUserUserId).observe(.value, with: {
                [unowned self] snapshot in
                
                if snapshot.exists() {
                    let chatMate = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    
                    if (self.currentUser!.blockedUsersList.contains(chatMate.objectId) || chatMate.blockedUsersList.contains(self.currentUser!.objectId)) {
                        self.inputToolbar.isHidden = true
                        self.blockedButton = self.showBlockedUserMessage()
                        self.view.addSubview(self.blockedButton!)
                    } else {
                        self.inputToolbar.isHidden = false
                        if let button = self.blockedButton {
                            button.removeFromSuperview()
                        }
                    }
                    
                }
            })
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ChatViewController.backAction))
        
        loadImage(imageUrl: (post?.imageUrl[0])!){ [unowned self] (image) in
            let postImageButton  = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(ChatViewController.seeProfile))
            postImageButton.setBackgroundImage(resizeImage(image: image, targetSize: CGSize(width: 100.0, height: 40.0)), for: .normal, barMetrics: .default)
            
            let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_settings_white_24dp"), style: .plain, target: self, action: #selector(ChatViewController.showUserOptions))
            
            self.navigationItem.rightBarButtonItems = [settingsButton, postImageButton]
        }
    }
    
    func sendMessage(text: String?, date: Date) {
        
        var outgoingMessage: OutgoingMessage?
     
        if let text = text {
            
            let encryptedText = encrypt(plainText: text, password: chatRoomId)
            
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: currentUser!.objectId, senderName: currentUser!.userName, date: date, status: kDELIVERED, type: kTEXT, receiverId: (withUser?.objectId)!, postId: (post?.postId)!)
        }
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary, vc: self)
        finishSendingMessage()
    }
    
    
    func loadMessegas() {
        //createTypingObservers()
        
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        chatRef.child(chatRoomId).observe(.childAdded, with: {
            [unowned self] snapshot in
    
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
            if snapshot.exists() {
                self.updateMessage(item: snapshot.value as! NSDictionary)
            }
        })
        
        chatRef.child(chatRoomId).observeSingleEvent(of: .value, with: {
            [weak self] snapshot in
            
            self?.insertMessages()
            self?.finishReceivingMessage(animated: false)
            self?.initialLoadComplete = true
            
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
            _ = insertMessage(item: item)
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
            _ = insertNewMessage(item: item)
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
            
            if snapshot.exists() {
                if snapshot.key != FUser.currentId() {
                    let typing = snapshot.value as! Bool
                    self.showTypingIndicator = typing
                    if typing {
                        self.scrollToBottom(animated: true)
                    }
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
