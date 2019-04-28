//
//  UpdateUsernameVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/26/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class UpdateUsernameVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: FancyField!
    @IBOutlet weak var updateUsernameButtonView: FancyButton!
    var user: User?
    
    @IBAction func updateUsernameButton(_ sender: Any) {
        if self.usernameTextField.text == self.user?.userName {
            return
        }
        if self.usernameTextField.text != "", (self.usernameTextField.text?.count)! > 0 {
            self.showSpinner(onView: self.view)
            self.usernameTextField.isHidden = true
            self.updateUsernameButtonView.isHidden = true
            
            firebase.child(kUSER).child(user!.objectId).child(kUSERNAME).setValue(self.usernameTextField.text)
            
            self.removeSpinner()
            
            self.showAlert("Success!", message: "Username successfully updated.")
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = self.user {
            self.usernameTextField.text = user.userName
        }
    }
}
