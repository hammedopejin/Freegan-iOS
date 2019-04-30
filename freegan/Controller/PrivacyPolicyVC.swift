//
//  PrivacyPolicyVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/29/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {
    
    var webView: WKWebView!
    
    override func loadView() {
        self.webView = WKWebView()
        self.view =  self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://docs.google.com/document/d/e/2PACX-1vSigTJFkQwupqxC7FwW27fEfSzLXJl2WMMjfZnFpAPE8lLfSb6vRvUhez3belX-OI68MQp26Fc4pvdJ/pub")
        self.webView.load(URLRequest(url: url!))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(TermsAndConitionsVC.backAction))
        
        self.navigationItem.title = "Privacy Policy"
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
