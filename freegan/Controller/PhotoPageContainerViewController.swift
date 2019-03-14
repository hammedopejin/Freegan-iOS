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
    
    var verticalPageViewController : UIPageViewController? = nil
    
    var currentViewController: PhotoZoomViewController {
        return self.pageViewController.viewControllers![0] as! PhotoZoomViewController
    }
    
    var images = [[UIImage]]()
    var posts: [Post]!
    var currentIndex = 0
    var vertIndex = 0
    var nextIndex: Int?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
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
        vc.image = self.images[self.currentIndex][0]
        
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
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:

                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
                
                
                if self.vertIndex > 0 {
                    self.vertIndex -= 1
                    vc.image = self.images[self.currentIndex][self.vertIndex]
                    
                    let viewControllers = [
                        vc
                    ]
                    
                    self.pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: false, completion: nil)
                    
                }
                
            case UISwipeGestureRecognizer.Direction.up:

                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
                
                
                if self.posts[self.currentIndex].imageUrl.count > self.vertIndex + 1 {
                    self.vertIndex += 1
                    vc.image = self.images[self.currentIndex][self.vertIndex]
                
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
        
        vc.image = self.images[self.currentIndex - 1][0]
        vc.index = currentIndex - 1
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.posts.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        
        vc.image = self.images[self.currentIndex + 1][0]
        vc.index = currentIndex + 1
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
            previousViewControllers.forEach { vc in
                let zoomVC = vc as! PhotoZoomViewController
                zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
            }
            
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
        return self.currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.currentViewController.scrollView.convert(self.currentViewController.imageView.frame, to: self.currentViewController.view)
    }
}
