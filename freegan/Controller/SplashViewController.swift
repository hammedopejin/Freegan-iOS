//
//  SplashViewController.swift
//  freegan
//
//  Created by Hammed opejin on 7/29/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if Auth.auth().currentUser != nil {
            
            let tab = goToHome()
            appDelegate.window?.rootViewController = tab
            
        } else {
            
            let registerVC = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
            appDelegate.window?.rootViewController = registerVC
            
        }
    }
    
}
