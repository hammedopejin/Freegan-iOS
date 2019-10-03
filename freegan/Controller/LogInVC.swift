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

class LogInVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailField.delegate =  self
        pwdField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
    }
 
    @IBAction func logInTapped(_ sender: Any) {
        if emailField.text == "" || pwdField.text == "" {
            self.showToast(message : "All text fields must be entered properly!")
            return
        }
        
        if let email = emailField.text, let pwd = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { [unowned self] (user, error) in
                if error == nil {
                    if let user = user {
                        self.completeSignIn(id: user.user.uid)
                    }
                } else {
                    self.showToast(message : "Login failed, invalid email and/or password")
                }
            })
        }
    }
    
    @IBAction func gotoLogin(_ sender: Any) {
        
        let register = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterVC")
        self.present(register, animated: true, completion: nil)
    }
 
    func completeSignIn(id: String) {
        let _ = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
