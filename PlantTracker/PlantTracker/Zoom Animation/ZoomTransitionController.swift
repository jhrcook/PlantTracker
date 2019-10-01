//
//  ZoomTransitionController.swift
//  PlantTracker
//
//  Created by Joshua on 8/10/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit


/**
A custom zoom transition for the transition from an `ImageCollectionViewController` to an
`ImagePagingCollectionViewController` when a cell is tapped. It also handles the retraction
transition. It was built to mimic the transition used in the native iPhone Photos app.
 
 This custom animation was documented and explained in complete detail in the links provided below.

- SeeAlso:
    [GitHub](https://github.com/jhrcook/PlantTracker)
    [EditPlantLevelManager_notes.md](https://github.com/jhrcook/PlantTracker/blob/master/EditPlantLevelManager_notes.md).
*/
class ZoomTransitionController: NSObject {
    
    /// The delegate being animated *from*.
    weak var fromDelegate: ZoomAnimatorDelegate?
    /// The delegate being animated *to*.
    weak var toDelegate: ZoomAnimatorDelegate?
    
    /// The animator to use for the transition. This is a custom animation that zooms from one image
    /// to another.
    let animator: ZoomAnimator
    
    /// The controller for the interactive transition during dismissal. Dragging up or down on the image
    /// initiates the interactive transition.
    let interactionController: ZoomDismissalInteractionController
    
    /// A `Boolean` for if the transition is interactive or not. Defaults to `false`.
    var isInteractive: Bool = false
    
    override init() {
        animator = ZoomAnimator()
        interactionController = ZoomDismissalInteractionController()
        super.init()
    }
}


extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
    
    /// Called when the transition begins for a presentation.
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = true
        self.animator.fromDelegate = fromDelegate
        self.animator.toDelegate = toDelegate
        return self.animator
    }
    
    /// Called when the transition begins for dismissal.
    /// The to and from delegates need to be swapped.
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = false
        let tmp = self.fromDelegate
        self.animator.fromDelegate = self.toDelegate
        self.animator.toDelegate = tmp
        return self.animator
    }
    
    /// Update the transition controller for a presentation or dismissal.
    /// It decides hether or not to use the interactive controller.
    /// The interactive controller uses the same animator, though.
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.isInteractive {
            return nil
        }
        
        self.interactionController.animator = animator
        return self.interactionController
    }
    
}



extension ZoomTransitionController: UINavigationControllerDelegate {
    
    /// Update the transition controller for a presentation or dismissal.
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // tell the animation which way it is going and set some stored properties
        if operation == .push {
            self.animator.isPresenting = true
            self.animator.fromDelegate = fromDelegate
            self.animator.toDelegate = toDelegate
        } else {
            // is called with `operation == .pop`
            self.animator.isPresenting = false
            let tmp = self.fromDelegate
            self.animator.fromDelegate = self.toDelegate
            self.animator.toDelegate = tmp
        }
        
        return self.animator
    }
    
    /// Update the transition controller for a presentation or dismissal.
    /// It decides hether or not to use the interactive controller.
    /// The interactive controller uses the same animator, though.
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if !self.isInteractive {
            return nil
        }
        
        self.interactionController.animator = animator
        return self.interactionController
    }
    
}


extension ZoomTransitionController {
    
    /// Tells the `interactionController` that the user panned.
    /// - parameter gestureRecognizer: The pan gesture responsible for the function call.
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
    }
}
