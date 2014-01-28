//
//  EZRaiseAnimation.m
//  FeatherCV
//
//  Created by xietian on 14-1-28.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRaiseAnimation.h"
#import "EZExtender.h"
@implementation EZRaiseAnimation

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //Get references to the view hierarchy
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //Insert 'to' view into the hierarchy
    [containerView addSubview:toViewController.view];
    
    //90 degree transform away from the user
    CGFloat finalY = fromViewController.view.frame.origin.y;
    CGFloat beginY = fromViewController.view.frame.origin.y + fromViewController.view.frame.size.height;
    
    //Set anchor points for the views
    if (self.type == AnimationTypePresent) {
        //[self setAnchorPoint:CGPointMake(1.0, 0.5) forView:toViewController.view];
        //[self setAnchorPoint:CGPointMake(0.0, 0.5) forView:fromViewController.view];
        
    } else if (self.type == AnimationTypeDismiss) {
        //[self setAnchorPoint:CGPointMake(0.0, 0.5) forView:toViewController.view];
        //[self setAnchorPoint:CGPointMake(1.0, 0.5) forView:fromViewController.view];
        CGFloat tmpBegin = beginY;
        beginY = finalY;
        finalY = tmpBegin;
    }
    toViewController.view.y = beginY;
    
    //Animate the transition, applying transform to 'from' view and removing it from 'to' view
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //fromViewController.view.layer.transform = t;
        //toViewController.view.layer.transform = CATransform3DIdentity;
        toViewController.view.y = finalY;
    } completion:^(BOOL finished) {
        //Reset z indexes (otherwise this will affect other transitions)
        //fromViewController.view.layer.zPosition = 0.0;
        //toViewController.view.layer.zPosition = 0.0;
        [transitionContext completeTransition:YES];
    }];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    //NSLog(@"transitionDuration get called, caller:%@", [NSThread callStackSymbols]);
    return 0.5;
}

#pragma mark - Helper Methods

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = oldOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}


@end
