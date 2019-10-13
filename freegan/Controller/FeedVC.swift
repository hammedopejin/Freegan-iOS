//
//  FeedVC.swift
//  freegan
//
//  Created by Hammed opejin on 1/17/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MapKit
import CoreLocation
import GeoFire
import UserNotifications

class FeedVC: UIViewController {
    
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
    var posters = Array(repeating: FUser(), count: 20)
    var posts = [Post]()
    var filteredPosts = [Post]()
    var currentUser: FUser?
    var postIds = [String]()
    var askLocationFlag = false
    let PAGE_LOAD_SIZE = 10
    let GEOGRAPHIC_RADIUS = 50.0
    var totalLoadSize = 0
  
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var profileImgUrl: String!
    var userImgUrl: String!
    
    var postVC: PostVC?
    
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearch()
        setBar()
        
        //Manually set the collectionView frame to the size of the view bounds
        //(this is required to support iOS 10 devices and earlier)
        self.collectionView.frame = self.view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)!).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if snapshot.exists() {
                self.currentUser = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                self.registerForPushNotifications()
                if (self.currentUser?.latitude == nil || self.currentUser?.longitude == nil) {
                    self.requestLocation()
                } else {
                    self.checkPosts()
                }
                
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        //if the application launches in landscape mode, the safeAreaInsets
        //need to be updated from 0.0 if the device is an iPhone X model. At
        //application launch this function is called before viewWillLayoutSubviews()
        if #available(iOS 11, *) {
            self.currentLeftSafeAreaInset = self.view.safeAreaInsets.left
            self.currentRightSafeAreaInset = self.view.safeAreaInsets.right
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
            
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            self.collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            
            self.collectionView.contentInsetAdjustmentBehavior = .never
            let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
            let navBarHeight : CGFloat = navigationController?.navigationBar.frame.height ?? 0
            self.edgesForExtendedLayout = .all
            let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
            
            if UIDevice.current.orientation.isLandscape {
                self.collectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: self.currentLeftSafeAreaInset, bottom: tabBarHeight, right: self.currentRightSafeAreaInset)
            }
            else {
                self.collectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: 0.0, bottom: tabBarHeight, right: 0.0)
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
            if self.viewIfLoaded?.window != nil {
                
                coordinator.animate(alongsideTransition: { [unowned self] _ in
                    
                    //This needs to be called inside viewWillTransition() instead of viewWillLayoutSubviews()
                    //for devices running iOS 10.0 and earlier otherwise the frames for the view and the
                    //collectionView will not be calculated properly.
                    self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    self.collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    
                }, completion: { [unowned self] _ in
                    
                    //Invalidate the collectionViewLayout
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    
                })
                
            }
                //Otherwise, do not animate the transition
            else {
                
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                self.collectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                
                //Invalidate the collectionViewLayout
                self.collectionView.collectionViewLayout.invalidateLayout()
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = navigationController
            let vc = segue.destination as! PhotoPageContainerViewController
            nav?.delegate = vc.transitionController
            vc.transitionController.fromDelegate = self
            vc.transitionController.toDelegate = vc
            vc.delegate = self
            vc.currentIndex = selectedIndexPath.row
            vc.posts = isFiltering() ? filteredPosts : posts
            vc.posters = posters
            vc.postImages = postImages
            vc.posterImages = posterImages
            vc.currentUser = currentUser
        } else if segue.identifier == "goToPost" {
            let vc = segue.destination as! PostVC
            vc.currentUser = currentUser
        }
    }
    
    @IBAction func gotoPostVC(_ sender: AnyObject) {
        guard let _ = currentUser?.latitude, let _ = currentUser?.longitude else {
            showToast(message: "Current location needed to post an item!")
            self.requestLocationPermission()
            return
        }
        self.showCameraLibraryOptions()
    }
    
    func createSearch() {
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .red
        searchController.searchBar.backgroundColor = .init(red: 73/255, green: 167/255, blue: 151/255, alpha: 1.0)
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setBar() {
        
        let logoButton = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: nil)
        logoButton.setBackgroundImage(resizeImage(image: UIImage(named: "freegan_logo_transparent")!, targetSize: CGSize(width: 60.0, height: 60.0)), for: .normal, barMetrics: .default)
        navigationItem.leftBarButtonItems = [logoButton]
    }
    
    func requestLocation() {
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        switch(CLLocationManager.authorizationStatus()) {
            
        // get the user location
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            if (currentUser?.latitude == nil || currentUser?.longitude == nil){
                self.requestLocationPermission()
            } else {
                self.askLocationFlag = true
            }
            break
            
        case .authorizedAlways:
            self.askLocationFlag = true
            break
        case .authorizedWhenInUse:
            self.askLocationFlag = true
            break
            
        }
        
        if (self.askLocationFlag){
            checkPosts()
        }
    }
    
    func requestLocationPermission() {
        
        self.askLocationFlag = true
        
        let alertController = UIAlertController(title: "Freegan", message: "Please go to Settings and turn on location permissions",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        switch(CLLocationManager.authorizationStatus()) {
            
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            self.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
        
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func showCameraLibraryOptions(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // This lines is for the popover you need to show in iPad
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.permittedArrowDirections = []
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let camera = UIAlertAction(title: "Camera", style: .default){ (alert: UIAlertAction!) in
            PostVC.useCamera = true
            self.performSegue(withIdentifier: "goToPost", sender: nil)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default){ (alert: UIAlertAction!) in
            PostVC.useCamera = false
            self.performSegue(withIdentifier: "goToPost", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(camera)
        optionMenu.addAction(library)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func checkPosts(){
        
        guard let _ = currentUser?.latitude, let _ = currentUser?.longitude else {
            if(askLocationFlag){
                showError(title: "No Freegan!", message: "User location needed to see posts in the area")
            }
            return
        }
        
        let geoRef = GeoFire(firebaseRef: firebase.child(kPOSTLOCATION))
        let query = geoRef.query(at: CLLocation(latitude: (currentUser?.latitude)!, longitude: (currentUser?.longitude)!), withRadius: GEOGRAPHIC_RADIUS)
        
        totalLoadSize = 0
        postIds.removeAll()
        posts.removeAll()
        
        query.observe(.keyEntered, with: { [unowned self] key, location in
            self.postIds.append(key)
        })
        
        query.observeReady { [unowned self] in
            if (self.postIds.count > 0) {
                if (self.PAGE_LOAD_SIZE < self.postIds.count) {
                    self.loadPosts(page_load_size: self.PAGE_LOAD_SIZE, offset: 0);
                } else {
                    self.loadPosts(page_load_size: self.postIds.count, offset: 0);
                }
            } else {
                self.showToast(message: "No Freegan posted in your area yet! Go ahead, post one")
            }
        }
    }
    
    func loadPosts(page_load_size: Int, offset: Int){
        
        var maxBoundary = page_load_size + offset;
        if (maxBoundary > postIds.count) {
            maxBoundary = postIds.count;
        }
        
        for i in offset..<maxBoundary {
            DataService.ds.REF_POSTS.child(postIds[i]).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let post = Post(postId: snapshot.key, postData: snapshot.value as! Dictionary<String, AnyObject>)
                    self.posts.append(post)
                    
                    self.collectionView.reloadData()
                }
            })
        }

    }
}

extension FeedVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering() ? filteredPosts.count : posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PhotoCollectionViewCell.self)", for: indexPath) as! PhotoCollectionViewCell
        
        let fetchedPosts = isFiltering() ? filteredPosts : posts
        var j = 0
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: fetchedPosts[indexPath.row].postUserObjectId)
            .observeSingleEvent(of: .value, with: {
                snapshot in
                
                if snapshot.exists() {
                    
                    let poster = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                    self.posters[indexPath.row] = poster
                    var ref = Storage.storage().reference(forURL: "gs://freegan-eabd2.appspot.com/user_images/ic_account_circle_black_24dp.png")
                    
                    if (!(poster.userImgUrl?.isEmpty)!){
                        ref = Storage.storage().reference(forURL: poster.userImgUrl!)
                    }
                    
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { [unowned self] (data, error) in
                        if error != nil {
                            print("MARK: Unable to download image from Firebase storage \(error.debugDescription)")
                            
                        } else {
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    self.posterImages[indexPath.row] = img
                                    FeedVC.imageCache.setObject(img, forKey: poster.userImgUrl! as NSString)
                                }
                            }
                            
                        }
                    })
                }
                
            })
        
        for i in fetchedPosts[indexPath.row].imageUrl{
            
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
        
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        
        if indexPath.row >= self.totalLoadSize - 3 {
            if (PAGE_LOAD_SIZE < postIds.count) {
                loadPosts(page_load_size: PAGE_LOAD_SIZE, offset: totalItemsCount);
                totalLoadSize += PAGE_LOAD_SIZE;
            }
        }
        
        return cell
    }
}

extension FeedVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCell: CGFloat
        if UIScreen.main.bounds.size.width > 700{
            numberOfCell = 7.3
        } else if UIScreen.main.bounds.size.width > 500{
            numberOfCell = 5.3
        } else {
           numberOfCell = 3.3
        }
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell
        return CGSize(width: cellWidth, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            //Guard against nil return values
            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell else {
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
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0)
            }
            
            return guardedCell.frame
        }
            //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 120.0, height: 180.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
    
}

extension FeedVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        updateUserLocation(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted){
            if (currentUser?.latitude == nil || currentUser?.longitude == nil){
                showError(title: "No Freegan!", message: "User location needed to see posts in the area")
            }
        }
        
    }
}

//MARK: - SEARCH

extension FeedVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let search = searchController.searchBar.text else {
            return
        }
        filterFreegans(by: search)
    }
    
    //MARK: Helper func
    
    func isFiltering() -> Bool {
        return !searchController.searchBar.text!.isEmpty && searchController.isActive
    }
    
    func filterFreegans(by search: String) {
        filteredPosts = posts.filter({$0.description.lowercased().contains(search.lowercased())})
        collectionView.reloadData()
    }
}

extension FeedVC: PhotoPageContainerViewControllerDelegate {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension FeedVC: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {}
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {}
    
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
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top,
                          width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
        }
        return cellFrame
    }
 
}
