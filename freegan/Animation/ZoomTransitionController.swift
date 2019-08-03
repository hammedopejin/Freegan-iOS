//
//  ZoomTransitionController.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class ZoomTransitionController: NSObject {
    
    let animator: ZoomAnimator
    var isInteractive: Bool = false
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    override init() {
        animator = ZoomAnimator()
        super.init()
    }
}

extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        animator.fromDelegate = fromDelegate
        animator.toDelegate = toDelegate
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        let tmp = fromDelegate
        animator.fromDelegate = toDelegate
        animator.toDelegate = tmp
        return animator
    }
    
}

extension ZoomTransitionController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            animator.isPresenting = true
            animator.fromDelegate = fromDelegate
            animator.toDelegate = toDelegate
        } else {
            animator.isPresenting = false
            let tmp = fromDelegate
            animator.fromDelegate = toDelegate
            animator.toDelegate = tmp
        }
        
        return animator
    }
    
}
