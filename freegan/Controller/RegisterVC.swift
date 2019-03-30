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
            //print("HAMMED: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    

    
    
    func completeSignIn(id: String) {
        // Load User Info/Data
        let keychainResult = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        print("HAMMED: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
   
    @IBAction func registerTapped(_ sender: Any) {
        if emailField.text == nil || userNameField.text == nil || pwdField.text == nil {
            self.showToast(message : "All text fields must be entered properly!")
            return
        }
        if let email = emailField.text, let pwd = pwdField.text, let userName = userNameField.text {
            
            Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                if error != nil {
                    self.showToast(message : "Registration failed, invalid credentials")
                } else {
                    print("HAMMED: Successfully authenticated with Firebase")
                    if let user = user {
                                    User.registerUserWith(email: email, firuseruid: user.user.uid, userName: userName)
                                    self.completeSignIn(id: user.user.uid)
                    }
                }
            })
        }
    }
    
  
    @IBAction func gotoLogin(_ sender: Any) {
        let logIn = UIStoryboard(name: "Main", bundle:
            nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(logIn, animated: true, completion: nil)
    }
}
    

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height-100, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
