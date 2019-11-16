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
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            usernameTextField.text = user.userName
            usernameTextField.sizeToFit()
        }
    }
    
    @IBAction func updateUsernameButton(_ sender: Any) {
        if usernameTextField.text == user?.userName {
            return
        }
        if usernameTextField.text != "", (usernameTextField.text?.count)! > 0 {
            showSpinner(onView: view)
            usernameTextField.isHidden = true
            updateUsernameButtonView.isHidden = true
            
            firebase.child(kUSER).child(user!.objectId).child(kUSERNAME).setValue(usernameTextField.text)
            
            removeSpinner()
            
            showAlert(title: "Success!", message: "Username successfully updated.")
            presentingViewController?.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
 
}
