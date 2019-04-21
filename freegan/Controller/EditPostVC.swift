//
//  EditPostVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/21/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

class EditPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var firstPostImageView: UIImageView!
    
    @IBOutlet weak var secondPostImageView: UIImageView!
    
    @IBOutlet weak var thirdPostImageView: UIImageView!
    
    @IBOutlet weak var fourthPostImageView: UIImageView!
    
    @IBOutlet weak var postDescriptionText: FancyField!
    
    @IBOutlet weak var saveBotton: FancyButton!
    
    
    
}
