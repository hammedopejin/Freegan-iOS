//
//  LogInVC.swift
//  freegan
//
//  Created by Hammed opejin on 1/18/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MobileCoreServices

class LogInVC : UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
    }
    
    func completeSignIn(id: String) {
        // Load User Info/Data
        let keychainResult = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        print("HAMMED: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    @IBAction func logInTapped(_ sender: Any) {
        if emailField.text == "" || pwdField.text == "" {
            self.showToast(message : "All text fields must be entered properly!")
            return
        }
        
        if let email = emailField.text, let pwd = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    if let user = user {
                        print("HAMMED: Email user authenticated with Firebase")
                        self.completeSignIn(id: user.user.uid)
                    }
                } else {
                    self.showToast(message : "Login failed, invalid email and/or password")
                }
            })
        }
    }
    
    
    
    @IBAction func gotoLogin(_ sender: Any) {
        
        let Register = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterVC")
        self.present(Register, animated: true, completion: nil)
    }
 
}
