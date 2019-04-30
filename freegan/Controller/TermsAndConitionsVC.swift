//
//  TermsAndConitionsVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/29/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConitionsVC: UIViewController {
    
    var webView: WKWebView!
    
    override func loadView() {
        self.webView = WKWebView()
        self.view =  self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://docs.google.com/document/d/e/2PACX-1vQ-9nRW3YDdq3M26rbNGOxsuxNdVU3jfVJl1H4L8SYmD7WY9KXotcW94oPySm5ew4i6aeVgFj3tQPId/pub")
        self.webView.load(URLRequest(url: url!))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(TermsAndConitionsVC.backAction))
        
        self.navigationItem.title = "Terms & Condition"
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
