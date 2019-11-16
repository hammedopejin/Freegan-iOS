//
//  ProfileVC.swift
//  freegan
//
//  Created by Hammed opejin on 4/16/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController {
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var selectedIndexPath: IndexPath!
    
    //These variables are used to hold any updates to the safeAreaInsets
    //that might not have been propagated to this ViewController. This is required
    //for supporting devices running on >= iOS 11. These will be set manually from
    //PhotoZoomViewController.swift to ensure any changes to the safeAreaInsets
    //after the device rotates are pushed to this ViewController. This is required
    //to ensure the collectionView.convert() function calculates the proper
    //frame result inside referenceImageViewFrameInTransitioningView()
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0
    
    
    let firebaseUser = DataService.ds.REF_USER_CURRENT
    
    var postImages = Array(repeating: Array(repeating: #imageLiteral(resourceName: "freegan_logo"), count: 4), count: 20)
    var posterImages = Array(repeating: #imageLiteral(resourceName: "freegan_logo"), count: 20)
    var posts = [Post]()
    var currentUser: FUser!
    var poster: FUser!
    var posterUserId: String!
    var blockedUsersList: [String] = []
    
    var profileImgUrl: String!
    var userImgUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let posterUserId = posterUserId {
            loadWithUser(withUserUserId: posterUserId) { [unowned self] (poster) in
                self.poster = poster
                self.blockedUsersList = poster.blockedUsersList
                self.loadPosts()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let poster = poster {
            firebase.child(kUSER).child(poster.objectId).updateChildValues([kBLOCKEDUSERSLIST : blockedUsersList])
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        //if the application launches in landscape mode, the safeAreaInsets
        //need to be updated from 0.0 if the device is an iPhone X model. At
        //application launch this function is called before viewWillLayoutSubviews()
        if #available(iOS 11, *) {
            currentLeftSafeAreaInset = view.safeAreaInsets.left
            currentRightSafeAreaInset = view.safeAreaInsets.right
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        //Only perform these changes for devices running iOS 11 and later. This is called
        //inside viewWillLayoutSubviews() instead of viewWillTransition() because when the
        //device rotates, the navBarHeight and statusBarHeight will be calculated inside
        //viewWillTransition() using the current orientation, and not the orientation
        //that the device will be at the end of the transition.
        
        //By the time that viewWillLayoutSubviews() is called, the views frames have been
        //properly updated for the new orientation, so the navBar and statusBar height values
        //can be calculated and applied directly as per the code below
        
        if #available(iOS 11, *) {
            
            view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size)
            collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size)
            
            collectionView.contentInsetAdjustmentBehavior = .never
            let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
            let navBarHeight : CGFloat = navigationController?.navigationBar.frame.height ?? 0
            edgesForExtendedLayout = .all
            let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
            
            if UIDevice.current.orientation.isLandscape {
                collectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: currentLeftSafeAreaInset, bottom: tabBarHeight, right: currentRightSafeAreaInset)
            }
            else {
                collectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: 0.0, bottom: tabBarHeight, right: 0.0)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if #available(iOS 11, *) {
            //Do nothing
        }
        else {
            
            //Support for devices running iOS 10 and below
            
            //Check to see if the view is currently visible, and if so,
            //animate the frame transition to the new orientation
            if viewIfLoaded?.window != nil {
                
                coordinator.animate(alongsideTransition: { [unowned self] _ in
                    
                    //This needs to be called inside viewWillTransition() instead of viewWillLayoutSubviews()
                    //for devices running iOS 10.0 and earlier otherwise the frames for the view and the
                    //collectionView will not be calculated properly.
                    self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    self.collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    
                }, completion: { _ in
                    
                    //Invalidate the collectionViewLayout
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    
                })
                
            }
                //Otherwise, do not animate the transition
            else {
                
                view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                
                //Invalidate the collectionViewLayout
                collectionView.collectionViewLayout.invalidateLayout()
                
            }
        }
    }
    
    @objc func showUserOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        
        let report = UIAlertAction(title: "Report User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            
            let reportVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ReportUserVC")
                as! ReportUserVC
            reportVC.poster = self.poster
            reportVC.currentUser = self.currentUser
            self.navigationController?.pushViewController(reportVC, animated: true)
            
        }
        
        let block = UIAlertAction(title: "Block User", style: .default){ [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.append(self.currentUser.objectId)
        }
        
        let unBlock = UIAlertAction(title: "Unblock User", style: .default) { [unowned self] (alert: UIAlertAction!) in
            self.blockedUsersList.remove(at: self.blockedUsersList.index(of:self.currentUser.objectId)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(report)
        
        if (blockedUsersList.contains(currentUser!.objectId)) {
            optionMenu.addAction(unBlock)
        } else {
            optionMenu.addAction(block)
        }
        
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func backActionWithPoster() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backActionDefault() {
        if let _ = self.posterUserId {
            navigationController?.popViewController(animated: true)
        } else {
            tabBarController?.selectedIndex = 0
        }
    }
    
    @objc func goToSettings() {
    
        let settingsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BaseVC") as! UITabBarController
        settingsVC.selectedIndex = 3
        tabBarController?.present(settingsVC, animated: true, completion: nil)
    }
    
    func loadPosts(){
        posts.removeAll()
        
        guard let poster = poster else {
            
            DataService.ds.REF_POSTS.queryOrdered(byChild: kPOSTUSEROBJECTID).queryEqual(toValue: self.currentUser.objectId).observe(.value, with: { [unowned self] snapshot in
                if snapshot.exists() {
                
                    let postData = snapshot.value as! Dictionary<String, AnyObject>
                    
                    for key in postData.keys {
                        let post = Post(postId: key, postData: postData[key] as! Dictionary<String, AnyObject>)
                        self.posts.append(post)
                    }
                    self.collectionView.reloadData()
                }
            })
            return
        }
        
        DataService.ds.REF_POSTS.queryOrdered(byChild: kPOSTUSEROBJECTID).queryEqual(toValue: poster.objectId).observe(.value, with: { [unowned self] snapshot in
            if snapshot.exists() {
                
                let postData = snapshot.value as! Dictionary<String, AnyObject>
                
                for key in postData.keys {
                    let post = Post(postId: key, postData: postData[key] as! Dictionary<String, AnyObject>)
                    self.posts.append(post)
                }
                self.collectionView.reloadData()
            }
        })
    }
    
    func setUpProfile() {
        
        if let currentUserId = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
        
            firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: currentUserId).observe(.value, with: {
                [unowned self] snapshot in
                
                if snapshot.exists() {
                    self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    
                    //Manually set the collectionView frame to the size of the view bounds
                    //(this is required to support iOS 10 devices and earlier)
                    self.collectionView.frame = self.view.bounds
                    
                    guard let posterUserId = self.posterUserId else {
                        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ProfileVC.backActionDefault))
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_settings_white_24dp"), style: .plain, target: self, action: #selector(ProfileVC.goToSettings))
                        
                        self.loadPosts()
                        return
                    }
                    
                    if self.currentUser!.objectId != posterUserId {
                        
                        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ProfileVC.backActionWithPoster))
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_settings_white_24dp"), style: .plain, target: self, action: #selector(ProfileVC.showUserOptions))
                        
                    } else {
                        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ProfileVC.backActionDefault))
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_settings_white_24dp"), style: .plain, target: self, action: #selector(ProfileVC.goToSettings))
                        
                        self.loadPosts()
                    }
                }
                
            })
        }
    }
    
}

extension ProfileVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PhotoCollectionViewCell.self)", for: indexPath) as! PhotoCollectionViewCell
        
        var j = 0
        
        for i in posts[indexPath.row].imageUrl{
            
            let ref = Storage.storage().reference(forURL: i)
            
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { [unowned self] (data, error) in
                if error != nil {
                    print("MARK: Unable to download image from Firebase storage \(error.debugDescription)")
                    
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            if (j == 0){
                                cell.imageView.image = img
                                FeedVC.imageCache.setObject(img, forKey: i as NSString)
                            }
                            self.postImages[indexPath.row][j] = img
                            j += 1
                        }
                    }
                }
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView: ProfileCollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as! ProfileCollectionReusableView
            
            if let user = poster {
                
                headerView.profileName.text = user.userName
                guard let imgUrl = user.userImgUrl, !imgUrl.isEmpty else {
                    headerView.profileImage.image = UIImage(named: "persoicon")
                    return headerView
                }
                
                let ref = Storage.storage().reference(forURL: imgUrl)
                
                ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("MARK: Unable to download image from Firebase storage \(error.debugDescription)")
                        
                    } else {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                
                                headerView.profileImage.image = img
                                FeedVC.imageCache.setObject(img, forKey: imgUrl as NSString)
                                
                            }
                        }
                    }
                })
                
                return headerView
                
            } else {
                
                if let currentUserId = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
                    
                    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: currentUserId).observe(.value, with: {
                        [unowned self] snapshot in
                        
                        if snapshot.exists() {
                            self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                            
                            headerView.profileName.text = self.currentUser.userName
                            guard let imgUrl = self.currentUser.userImgUrl, !imgUrl.isEmpty else {
                                headerView.profileImage.image = UIImage(named: "persoicon")
                                return
                            }
                                
                                let ref = Storage.storage().reference(forURL: imgUrl)
                                
                                ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                    if error != nil {
                                        print("MARK: Unable to download image from Firebase storage \(error.debugDescription)")
                                        
                                    } else {
                                        if let imgData = data {
                                            if let img = UIImage(data: imgData) {
                                                
                                                headerView.profileImage.image = img
                                                FeedVC.imageCache.setObject(img, forKey: imgUrl as NSString)
                                                
                                            }
                                        }
                                    }
                                })
                        }
                    })
                }
                
                return headerView
            }
        }
        
        return UICollectionReusableView()
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCell: CGFloat
        if UIScreen.main.bounds.size.width > 700{
            numberOfCell = 7.3
        }else if UIScreen.main.bounds.size.width > 500{
            numberOfCell = 5.3
        }else{
            numberOfCell = 3.3
        }
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell
        return CGSize(width: cellWidth, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let photoPageContainerViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoPageContainerViewController") as! PhotoPageContainerViewController
        
        var posters: Array<FUser>!
        if let user = poster {
            poster.blockedUsersList = blockedUsersList
            posters = Array(repeating: user, count: posts.count)
        } else {
            posters = Array(repeating: currentUser!, count: posts.count)
        }
        let nav = navigationController
        
        nav?.delegate = photoPageContainerViewController.transitionController
        photoPageContainerViewController.transitionController.fromDelegate = self
        photoPageContainerViewController.transitionController.toDelegate = photoPageContainerViewController
        photoPageContainerViewController.delegate = self
        photoPageContainerViewController.currentIndex = selectedIndexPath.row
        photoPageContainerViewController.posts = posts
        photoPageContainerViewController.fromProfileFlag = true
        photoPageContainerViewController.posters = posters
        photoPageContainerViewController.posterImages = posterImages
        photoPageContainerViewController.postImages = postImages
        photoPageContainerViewController.currentUser = currentUser
        
        navigationController?.pushViewController(photoPageContainerViewController, animated: true)
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            //Guard against nil return values
            guard let guardedCell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0)
            }
            
            return guardedCell.frame
        }
            //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
    
}

extension ProfileVC: PhotoPageContainerViewControllerDelegate {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension ProfileVC: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {}
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = collectionView.cellForItem(at: selectedIndexPath) as! PhotoCollectionViewCell
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            collectionView.scrollToItem(at: selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > view.frame.height - collectionView.contentInset.bottom {
            collectionView.scrollToItem(at: selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath)
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
        }
        return cellFrame
    }
    
}
