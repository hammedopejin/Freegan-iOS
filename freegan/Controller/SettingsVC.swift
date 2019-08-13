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
import CoreLocation

class SettingsVC: UITableViewController {
    
    var currentUser: FUser?
    var imagePicker: UIImagePickerController!
    var cam: Camera?
    var locationAddress = ""
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        cam = Camera(delegate_: self)
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observe(.value, with: {
            [unowned self] snapshot in
            
            if snapshot.exists() {
                self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                if let lat = self.currentUser?.latitude, let lon = self.currentUser?.longitude {
                    self.getAddressFromLatLong(latitude: lat, with: lon) { [unowned self] address, location in
                        self.currentLocation = location
                        self.locationAddress = address ?? ""
                        self.tableView.reloadData()
                    }
                }
               
            }
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoUsername" {
            let vc = segue.destination as! UpdateUsernameVC
            vc.user = currentUser
        }
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
            cell.detailTextLabel?.text = locationAddress
            
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
            showCameraLibraryOptions()
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            performSegue(withIdentifier: "gotoUsername", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            performSegue(withIdentifier: "gotoEmail", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 3 {
            performSegue(withIdentifier: "gotoPassword", sender: nil)
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            let locationVC = LocationVC()
            locationVC.currentLocation = currentLocation
            self.show(locationVC, sender: self)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            //show Help
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let termsVC = TermsAndConitionsVC()
            termsVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(termsVC, animated: true)
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            let privacyVC = PrivacyPolicyVC()
            privacyVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(privacyVC, animated: true)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            showLogoutView()
        }
    }
    
    @IBAction func backToProfile(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    func showLogoutView(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive){ [unowned self] (alert: UIAlertAction!) in
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func logOut(){
    
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("HAMMED: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
    
        let login = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        present(login, animated: true, completion: nil)
    }
    
    func showCameraLibraryOptions(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let camera = UIAlertAction(title: "Camera", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.cam!.presentPhotoCamera(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.cam!.presentPhotoLibrary(target: self, canEdit: true, imagePicker: self.imagePicker)
        }
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(camera)
        optionMenu.addAction(library)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func uploadPicture(img: UIImage) {
        
        showSpinner(onView: view)
        
        if let imgData = img.jpegData(compressionQuality: 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let ref = DataService.ds.REF_USER_IMAGES.child(imgUid)
            
            let _ = ref.putData(imgData, metadata: metadata) { [unowned self] (metadata, error) in
                ref.downloadURL { [unowned self] (url, error) in
                    guard let downloadURL = url else {
                        
                        return
                    }
                    self.postPictureToFirebase(imgUrl: downloadURL.absoluteString)
                }
            }
        }
    }
    
    func postPictureToFirebase(imgUrl: String) {
        if(!(currentUser?.userImgUrl?.isEmpty)!){
            if let imgUrl = currentUser?.userImgUrl {
                let toReplace = storage.reference(forURL: imgUrl)
                toReplace.delete(completion: nil)
            }
        }
        
        firebase.child(kUSER).child(currentUser!.objectId).child(kUSERIMAGEURL).setValue(imgUrl)
        removeSpinner()
        showError (title: "Success!", message: "User Picture successfully updated.")
    }
    
    func getAddressFromLatLong(latitude: Double, with longitude: Double, completion: @escaping (String?, CLLocation?) -> Void) {
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(latitude)")!
        let lon: Double = Double("\(longitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        var addressString : String = ""
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    completion(nil, nil)
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
        
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.administrativeArea != nil {
                        addressString = addressString + pm.administrativeArea! + " "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    if let location = pm.location {
                        completion(addressString, location)
                    } else {
                        completion(addressString, nil)
                    }
                }
        })
        
    }
    
}

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            uploadPicture(img: image)
        } else {
            print("TAG: A valid image wasn't selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
