//
//  UserTabController.swift
//  freegan
//
//  Created by Hammed opejin on 4/17/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class UserTabController: UITabBarController {
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observe(.value, with: {
            snapshot in
            
            if snapshot.exists() {
                self.currentUser = User.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
            }

        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
