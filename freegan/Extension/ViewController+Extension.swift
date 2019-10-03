//
//  ViewController+Extension.swift
//  freegan
//
//  Created by Hammed opejin on 7/29/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import CoreLocation
import  SwiftKeychainWrapper

var vSpinner : UIView?
extension UIViewController {
    
    func goToHome() -> UITabBarController  {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "BaseVC") as! UITabBarController
    }
    
    func updateUserLocation(location: CLLocationCoordinate2D){
        
        let locationData: [AnyHashable : Any] = [kLATITUDE : location.latitude, kLONGITUDE : location.longitude]
        firebase.child(kUSER).child(KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).updateChildValues(locationData)
    }
    
    func loadWithUser(withUserUserId: String, withUser: @escaping(_ withUser: FUser) -> Void){
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: withUserUserId)
            .observeSingleEvent(of: .value, with: {
                snapshot in
                
                if snapshot.exists() {
                    
                    let user = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    withUser(user)
                }
                
            })
    }
    
    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func showAlertWithEscaping(title: String, message: String, completion: @escaping (_ vc: UIViewController) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completion(self)
            }
        }
        
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 175, y: view.frame.size.height - 200, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
