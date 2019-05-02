//
//  UpdatePasswordVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/26/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class UpdatePasswordVC: UIViewController {

    @IBOutlet weak var updatePasswordText1: FancyField!
    
    
    @IBOutlet weak var updatePasswordText2: FancyField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user = Auth.auth().currentUser
        
    }
    
    func updateUserPassword(_ password: String) {
       
        guard let user = self.user else {
            return
        }
        self.showSpinner(onView: self.view)
        
        user.updatePassword(to: password) { (completion) in
            if (completion != nil) {
                self.removeSpinner()
                self.showError("Error changing password!", message: completion!.localizedDescription)
                print(completion.debugDescription)
            } else {
                self.removeSpinner()
                
                self.showAlert("Success!", message: "Password successfully updated.")
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func updatePasswordButton(_ sender: Any) {
        guard let password1 = self.updatePasswordText1.text, let password2 = self.updatePasswordText2.text else {
            return
        }
        
        if password1 != password2 {
            self.showError("Error!", message: "Enter new password twice correctly")
            return
        }
        
        if password1 != "", password1.count > 0 {
            self.updateUserPassword(password1)
        }
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
