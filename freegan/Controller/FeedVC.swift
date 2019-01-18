//
//  FeedVC.swift
//  freegan
//
//  Created by Hammed opejin on 1/17/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MobileCoreServices

class FeedVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID){
            print("HAMMED: ID found in keychain")
        }
        
        logOut()
    }
    
    func logOut(){
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("HAMMED: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        
        
        let register = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterVC")
        self.present(register, animated: true, completion: nil)
    }
    
    
}
