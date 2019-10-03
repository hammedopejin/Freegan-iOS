//
//  PhotoPageContainerViewController.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

class PhotoPageContainerViewController: UIViewController {
    
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: PhotoZoomViewController {
        return self.pageViewController.viewControllers![0] as! PhotoZoomViewController
    }
    
    var postImages = [[UIImage]]()
    var posterImages = [UIImage]()
    var posters = [FUser]()
    var posts: [Post]!
    var currentUser: FUser!
    var currentIndex = 0
    var vertIndex = 0
    var nextIndex: Int?
    var fromProfileFlag = false
    
    var transitionController = ZoomTransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDown)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.index = currentIndex
        vc.postImage = postImages[currentIndex][0]
        vc.posterImage = posterImages[currentIndex]
        vc.post = posts[currentIndex]
        vc.poster = posters[currentIndex]
        vc.blockedUsersList = posters[currentIndex].blockedUsersList
        if posters[currentIndex].objectId == currentUser.objectId {
            vc.forSelf = true
        } else {
            vc.forSelf = false
        }
        vc.fromProfileFlag = fromProfileFlag
        vc.currentUser = currentUser
        
        let viewControllers = [
            vc
        ]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    @objc
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:

                if vertIndex > 0 && posts[self.currentIndex].imageUrl.count > 1{
                    vertIndex -= 1
                    vc.postImage = postImages[currentIndex][vertIndex]
                    vc.posterImage = posterImages[currentIndex]
                    vc.post = posts[currentIndex]
                    vc.poster = posters[currentIndex]
                    vc.blockedUsersList = posters[currentIndex].blockedUsersList
                    vc.currentUser = currentUser
                    if posters[currentIndex].objectId == currentUser.objectId {
                        vc.forSelf = true
                    } else {
                        vc.forSelf = false
                    }
                    vc.fromProfileFlag = fromProfileFlag
                    vc.index = currentIndex
                    let viewControllers = [
                        vc
                    ]
                    pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: false, completion: nil)
                }
                
            case UISwipeGestureRecognizer.Direction.up:
                
                if posts[currentIndex].imageUrl.count > vertIndex + 1 && vertIndex < 5{
                    vertIndex += 1
                    vc.postImage = postImages[currentIndex][vertIndex]
                    vc.posterImage = posterImages[currentIndex]
                    vc.post = posts[currentIndex]
                    vc.poster = posters[currentIndex]
                    vc.blockedUsersList = posters[currentIndex].blockedUsersList
                    vc.currentUser = currentUser
                    if posters[currentIndex].objectId == currentUser.objectId {
                        vc.forSelf = true
                    } else {
                        vc.forSelf = false
                    }
                    vc.fromProfileFlag = fromProfileFlag
                    vc.index = currentIndex
                    let viewControllers = [
                        vc
                    ]
                    pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
                }

            default:
                break
            }
        }
    }
}

extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == 0 {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        
        vc.postImage = postImages[currentIndex - 1][0]
        vc.posterImage = posterImages[currentIndex - 1]
        vc.post = posts[currentIndex - 1]
        vc.poster = posters[currentIndex - 1]
        vc.blockedUsersList = posters[currentIndex - 1].blockedUsersList
        vc.currentUser = currentUser
        if posters[currentIndex - 1].objectId == currentUser.objectId {
            vc.forSelf = true
        } else {
            vc.forSelf = false
        }
        vc.fromProfileFlag = fromProfileFlag
        vc.index = currentIndex - 1
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (posts.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        
        vc.postImage = postImages[currentIndex + 1][0]
        vc.posterImage = posterImages[currentIndex + 1]
        vc.post = posts[currentIndex + 1]
        vc.poster = posters[currentIndex + 1]
        vc.blockedUsersList = posters[currentIndex + 1].blockedUsersList
        vc.currentUser = currentUser
        if posters[currentIndex + 1].objectId == currentUser.objectId {
            vc.forSelf = true
        } else {
            vc.forSelf = false
        }
        vc.fromProfileFlag = fromProfileFlag
        vc.index = currentIndex + 1
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVC = pendingViewControllers.first as? PhotoZoomViewController else {
            return
        }
        
        nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && nextIndex != nil) {
            currentIndex = nextIndex!
            delegate?.containerViewController(self, indexDidUpdate: currentIndex)
        }
        
        nextIndex = nil
    }
    
}

extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return currentViewController.postImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return currentViewController.postImageView.convert(currentViewController.view.frame, to: currentViewController.postImageView)
    }
}
