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
        
        user = Auth.auth().currentUser
        
    }
    
    @IBAction func updatePasswordButton(_ sender: Any) {
        guard let password1 = updatePasswordText1.text, let password2 = updatePasswordText2.text else {
            return
        }
        
        if password1 != password2 {
            showError(title: "Error!", message: "Enter new password twice correctly")
            return
        }
        
        if password1 != "", password1.count > 0 {
            updateUserPassword(password1)
        }
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUserPassword(_ password: String) {
        
        guard let user = user else {
            return
        }
        showSpinner(onView: view)
        
        user.updatePassword(to: password) { [unowned self] (completion) in
            if (completion != nil) {
                self.removeSpinner()
                self.showError(title: "Error changing password!", message: completion!.localizedDescription)
                print(completion.debugDescription)
            } else {
                self.removeSpinner()
                
                self.showAlert(title: "Success!", message: "Password successfully updated.")
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}
