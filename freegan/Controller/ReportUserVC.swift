//
//  ReportUserVC.swift
//  freegan
//
//  Created by Hammed opejin on 10/8/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ReportUserVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sendButtonView: FancyButton!
    
    var currentUser: FUser!
    var poster: FUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.delegate = self
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        guard let description = descriptionTextView.text, description != "" else {
            showToast(message: "Report message must have description!")
            return
        }
        
        descriptionTextView.isHidden = true
        sendButtonView.isHidden = true
        showSpinner(onView: view)
        
        postToFirebase(message: description)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func postToFirebase(message: String) {
        let date = Date()
        let time = dateFormatterWithTime().string(from: date)
        
        let messageRef = firebase.child(kREPORTMESSAGE).childByAutoId()
        let messageId: String = messageRef.key!
        
        let message: Dictionary<String, AnyObject> = [
            kMESSAGE : descriptionTextView.text! as AnyObject,
            kMESSAGEID : messageId as AnyObject,
            kSENDERID : currentUser.objectId as AnyObject,
            kSENDERNAME : currentUser.userName as AnyObject,
            kPOSTERID : poster.objectId as AnyObject,
            kPOSTERNAME : poster.userName as AnyObject,
            kREPORTDATE : time as AnyObject,
            kTYPE : kTYPE as AnyObject
        ]
        
        messageRef.setValue(message)
        
        removeSpinner()
        descriptionTextView.text = ""
        
        showAlertWithEscaping(title: "Success!", message: "Complaint sent successfully.") {
            [unowned self] view in
            view.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}
