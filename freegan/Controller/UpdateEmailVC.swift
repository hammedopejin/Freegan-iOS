//
//  UpdateEmailVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/26/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class UpdateEmailVC: UIViewController {
    
    @IBOutlet weak var updateEmailText: FancyField!
    
    var user: User?
    
    @IBAction func updateEmailButton(_ sender: Any) {
  
        
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = self.user {
            self.updateEmailText.text = user.email
        }
    }
    
}
