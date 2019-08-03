//
//  RegisterVC.swift
//  freegan
//
//  Created by Hammed opejin on 1/9/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MobileCoreServices

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    @IBOutlet weak var userNameField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
        
        if let _ = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID){
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        if emailField.text == "" || userNameField.text == "" || pwdField.text == "" {
            self.showToast(message : "All text fields must be entered properly!")
            return
        }
        if let email = emailField.text, let pwd = pwdField.text, let userName = userNameField.text {
            
            Auth.auth().createUser(withEmail: email, password: pwd, completion: { [unowned self] (user, error) in
                if error != nil {
                    self.showToast(message : "Registration failed, invalid credentials")
                } else {
                    if let user = user {
                        FUser.registerUserWith(email: email, firuseruid: user.user.uid, userName: userName)
                        self.completeSignIn(id: user.user.uid)
                    }
                }
            })
        }
    }
    
    @IBAction func gotoLogin(_ sender: Any) {
        let logIn = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(logIn, animated: true, completion: nil)
    }
    
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}
