//
//  ZoomAnimator.swift
//  PlantTracker
//
//  Created by Joshua on 8/5/19.
//  Copyright © 2019 JHC Dev. All rights reserved.
//

import UIKit

class ZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // animation duration
    let duration = 0.2
    // is the animation presenting?
    var presenting = true
    // original frame the user taps
    var originFrame = CGRect.zero
    // run a function when the transition is dismissed
    var dismissCompletion: (() -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.view(forKey: .to)!
        // animate on `imageView` for both presenting (zoom in) and dismissing (zoom out)
        let imageView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        // get appropriate frames
        let initialFrame = presenting ? originFrame : imageView.frame
        let finalFrame = presenting ? imageView.frame : originFrame
        
        // calculate scale factors
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        // background fading
        imageView.backgroundColor = UIColor(alpha: presenting ? 0.0 : 1.0, red: 0, green: 0, blue: 0)
        
        // scale and place `imageView` over the initial frame
        if presenting {
            imageView.transform = scaleTransform
            imageView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            imageView.clipsToBounds = true
        }
        
        imageView.layer.masksToBounds = true
        
        // `toView` behind `imageView`
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubviewToFront(imageView)
        
        // animation
//        let animationOptions = UIView.AnimationOptions()
        UIView.animate(withDuration: duration, delay: 0.0, animations: {
            imageView.transform = self.presenting ? .identity : scaleTransform
            imageView.backgroundColor = UIColor(alpha: self.presenting ? 1.0 : 0.0, red: 0, green: 0, blue: 0)
            imageView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: { _ in
            if !self.presenting { self.dismissCompletion?() }
            transitionContext.completeTransition(true)
        })
        
    }
    
}
