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
    var posters = [User]()
    var posts: [Post]!
    var currentUser: User!
    var currentIndex = 0
    var vertIndex = 0
    var nextIndex: Int?
    
    var transitionController = ZoomTransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.index = self.currentIndex
        vc.postImage = self.postImages[self.currentIndex][0]
        vc.posterImage = self.posterImages[self.currentIndex]
        vc.post = self.posts[self.currentIndex]
        vc.poster = self.posters[self.currentIndex]
        vc.currentUser = self.currentUser
        
        let viewControllers = [
            vc
        ]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:

                if self.vertIndex > 0 && self.posts[self.currentIndex].imageUrl.count > 1{
                    self.vertIndex -= 1
                    print(self.vertIndex)
                    vc.postImage = self.postImages[self.currentIndex][self.vertIndex]
                    vc.posterImage = self.posterImages[self.currentIndex]
                    vc.post = self.posts[self.currentIndex]
                    vc.poster = self.posters[self.currentIndex]
                    vc.currentUser = self.currentUser
                    vc.index = self.currentIndex
                    let viewControllers = [
                        vc
                    ]
                    self.pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: false, completion: nil)
                }
                
            case UISwipeGestureRecognizer.Direction.up:
                
                if self.posts[self.currentIndex].imageUrl.count > self.vertIndex + 1 && self.vertIndex < 5{
                    self.vertIndex += 1
                    print(self.vertIndex)
                    vc.postImage = self.postImages[self.currentIndex][self.vertIndex]
                    vc.posterImage = self.posterImages[self.currentIndex]
                    vc.post = self.posts[self.currentIndex]
                    vc.poster = self.posters[self.currentIndex]
                    vc.currentUser = self.currentUser
                    vc.index = self.currentIndex
                    let viewControllers = [
                        vc
                    ]
                    self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
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
        
        vc.postImage = self.postImages[self.currentIndex - 1][0]
        vc.posterImage = self.posterImages[self.currentIndex - 1]
        vc.post = self.posts[self.currentIndex - 1]
        vc.poster = self.posters[self.currentIndex - 1]
        vc.currentUser = self.currentUser
        vc.index = currentIndex - 1
        print("current index: " + String(self.currentIndex))
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.posts.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        
        vc.postImage = self.postImages[self.currentIndex + 1][0]
        vc.posterImage = self.posterImages[self.currentIndex + 1]
        vc.post = self.posts[self.currentIndex + 1]
        vc.poster = self.posters[self.currentIndex + 1]
        vc.currentUser = self.currentUser
        vc.index = currentIndex + 1
        print("current index: " + String(self.currentIndex))
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVC = pendingViewControllers.first as? PhotoZoomViewController else {
            return
        }
        
        self.nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {            
            self.currentIndex = self.nextIndex!
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
    
}

extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.currentViewController.postImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.currentViewController.postImageView.convert(self.currentViewController.view.frame, to: self.currentViewController.postImageView)
    }
}
