//
//  EZModalDissolveAnimation.m
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZModalDissolveAnimation.h"

@implementation EZModalDissolveAnimation

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //The view controller's view that is presenting the modal view
    UIView *containerView = [transitionContext containerView];
    
    if (self.type == AnimationTypePresent) {
        //The modal view itself
        UIView *modalView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
        UIView *parentView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        //modalView.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView insertSubview:modalView belowSubview:parentView];
        
        //Move off of the screen so we can slide it up
        //CGRect endFrame = modalView.frame;
        //modalView.frame = CGRectMake(endFrame.origin.x, containerView.frame.size.height, endFrame.size.width, endFrame.size.height);
        //[containerView bringSubviewToFront:modalView];
        //CGFloat finalHeight = - parentView.height;
        
        //Animate using spring animation
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //modalView.frame = endFrame;
            //_coverView.alpha = 1.0;
            parentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else if (self.type == AnimationTypeDismiss) {
        //The modal view itself
        //UIView *modalView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        UIView *parentView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
        UIView *modalView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        [containerView insertSubview:parentView belowSubview:modalView];

        //Grab a snapshot of the modal view for animating
        //parentView.y = - parentView.height;
        //[containerView addSubview:parentView];
        
        //Animate using keyframe animation
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]  animations:^{
            //modalView.frame = endFrame;
            //_coverView.alpha = 1.0;
            modalView.alpha = 0.0;
            parentView.alpha = 1.0;
            //parentView.y = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.type == AnimationTypePresent) return 0.8;
    else if (self.type == AnimationTypeDismiss) return 0.8;
    else return [super transitionDuration:transitionContext];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    EZDEBUG(@"will present the view");
    self.type = AnimationTypePresent;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    EZDEBUG(@"will dismiss the view");
    self.type = AnimationTypeDismiss;
    return self;
}

@end
