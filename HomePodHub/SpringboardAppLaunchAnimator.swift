//
//  SpringboardAppLaunchAnimator.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import UIKit

class SpringboardAppLaunchAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let duration = 0.5
  var presenting = true
  var originFrame = CGRect.zero
  
  var dismissCompletion: (() -> Void)?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: .to)!
    let appView = presenting ? toView : transitionContext.view(forKey: .from)!
    let initialFrame = presenting ? originFrame : appView.frame
    let finalFrame = presenting ? appView.frame : originFrame

    let xScaleFactor = presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width

    let yScaleFactor = presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height
    
    
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

    if presenting {
      appView.transform = scaleTransform
      appView.center = CGPoint(
        x: initialFrame.midX,
        y: initialFrame.midY)
      appView.clipsToBounds = true
    }

    appView.layer.cornerRadius = presenting ? 20.0 : 0.0
    appView.layer.masksToBounds = true
    
    containerView.addSubview(toView)
    containerView.bringSubviewToFront(appView)

    UIView.animate(
      withDuration: duration,
      delay: 0.0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.2,
      animations: {
        appView.transform = self.presenting ? .identity : scaleTransform
        appView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        appView.layer.cornerRadius = !self.presenting ? 20.0 : 0.0
      }, completion: { _ in
        if !self.presenting {
          self.dismissCompletion?()
        }
        
        transitionContext.completeTransition(true)
    })
  }
}
