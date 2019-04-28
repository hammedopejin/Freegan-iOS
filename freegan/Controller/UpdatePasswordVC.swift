//
//  UpdatePasswordVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/26/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class UpdatePasswordVC: UIViewController {

    @IBOutlet weak var updatePasswordText1: FancyField!
    
    
    @IBOutlet weak var updatePasswordText2: FancyField!
    
    var user: User?
    
    @IBAction func updatePasswordButton(_ sender: Any) {
        
        
    }
    
    
    @IBAction func backToSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
