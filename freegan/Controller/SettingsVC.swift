//
//  SettingsVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SettingsVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 5 }
        if section == 1 { return 4 }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
            cell.textLabel?.text = "Profile photo"
            return cell
        }
        
        if indexPath.row == 1 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
            cell.textLabel?.text = "User name"
            return cell
        }
        
        if indexPath.row == 2 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            cell.textLabel?.text = "Email"
            return cell
        }
        
        if indexPath.row == 3 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath)
            cell.textLabel?.text = "Password"
            return cell
        }
        
        if indexPath.row == 4 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = "Location"
            cell.detailTextLabel?.text = "Irvine, CA 92620"
            return cell
        }
        
        if indexPath.row == 0 && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath)
            cell.textLabel?.text = "Help"
            return cell
        }
        
        if indexPath.row == 1 && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath)
            cell.textLabel?.text = "Terms and Conitions"
            return cell
        }
        if indexPath.row == 2 && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "privacyCell", for: indexPath)
            cell.textLabel?.text = "Privacy Policy"
            return cell
        }
        
        if indexPath.row == 3 && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            //show Profile photo VC
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            //show User name VC gotoUsername
            performSegue(withIdentifier: "gotoUsername", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            //show Email VC gotoEmail
            performSegue(withIdentifier: "gotoEmail", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 3 {
            //show Password VC gotoPassword
            performSegue(withIdentifier: "gotoPassword", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            //show Location VC
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            //show Help
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            //show Terms and Conitions
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            //show Privacy Policy
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            showLogoutView()
        }
    }
    
    func showLogoutView(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive){ (alert: UIAlertAction!) in
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func logOut(){
    
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("HAMMED: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
    
        let login = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(login, animated: true, completion: nil)
    }
    
    @IBAction func backToProfile(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
}
