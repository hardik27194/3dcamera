//
//  EZCameraNaviAnimation.m
//  FeatherCV
//
//  Created by xietian on 14-3-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCameraNaviAnimation.h"

@implementation EZCameraNaviAnimation

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //Get references to the view hierarchy
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    EZDEBUG(@"CameraNaviAnimation from:%i, to:%i", (int)fromViewController.view, (int)toViewController.view);
    if (self.type == AnimationTypePresent) {
        //blurredView =[[UIImageView alloc]initWithImage:[fromViewController.view createBlurImage:70.0]];
        
        //[self setAnchorPoint:CGPointMake(1.0, 0.5) forView:toViewController.view];
        //[self setAnchorPoint:CGPointMake(0.0, 0.5) forView:fromViewController.view];
        //blurredView.tag = blurViewTag;
        //[toViewController.view insertSubview:blurredView atIndex:0];
        
        //[toViewController.view  insertSubview:blurredView atIndex:0];
        //blurredView.y = - blurredView.height;
        //toViewController.view.clipsToBounds = true;
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^(){
            fromViewController.view.alpha = 0.0;
        } completion:^(BOOL finish){
            //[fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else if (self.type == AnimationTypeDismiss) {
        toViewController.view.alpha = 1.0;
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^(){
            fromViewController.view.alpha = 0.0;
        } completion:^(BOOL finish){
            //[fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
    
    
    //[containerView addSubview:fromViewController.view];
    //toViewController.view.y = beginY;
    

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
