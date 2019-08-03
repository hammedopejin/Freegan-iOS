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
        webView = WKWebView()
        view =  webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://docs.google.com/document/d/e/2PACX-1vSigTJFkQwupqxC7FwW27fEfSzLXJl2WMMjfZnFpAPE8lLfSb6vRvUhez3belX-OI68MQp26Fc4pvdJ/pub")
        webView.load(URLRequest(url: url!))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(TermsAndConitionsVC.backAction))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let text = UITextField(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        text.textColor = UIColor.white
        text.text = "Privacy Policy"
        self.navigationItem.titleView = text
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
