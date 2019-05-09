//
//  UpdateEmailVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/26/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class UpdateEmailVC: UIViewController {
    
    @IBOutlet weak var updateEmailText: FancyField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user = Auth.auth().currentUser
        
        if let user = self.user {
            self.updateEmailText.text = user.email
            self.updateEmailText.sizeToFit()
        }
    }
    
    @IBAction func updateEmailButton(_ sender: Any) {
        guard let email = self.updateEmailText.text else {
            return
        }
        if email != "", email.count > 0 {
            self.updateUserEmail(email)
        }
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUserEmail(_ email: String) {
        
        guard let user = self.user, user.email != self.updateEmailText.text else {
            return
        }
        self.showSpinner(onView: self.view)
        user.updateEmail(to: email) { (completion) in
            if (completion != nil) {
                self.removeSpinner()
                self.showError("Error changing email address!", message: completion!.localizedDescription)
                print(completion.debugDescription)
            } else {
                self.removeSpinner()
                
                let date = Date()
                let time = dateFormatterWithTime().string(from: date)
                
                let reference = firebase.child(kUSER).child(user.uid)
                
                var values = [kEMAIL : email as AnyObject, kUPDATEDAT: time as AnyObject]
                
                reference.updateChildValues(values)
                
                values.removeAll()
                
                self.showAlert("Success!", message: "Username successfully updated.")
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}
