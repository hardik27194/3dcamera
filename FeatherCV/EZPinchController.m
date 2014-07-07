//
//  EZPinchController.m
//  TransitionsDemo
//
//  Created by xietian on 14-6-24.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import "EZPinchController.h"

@implementation EZPinchController

- (id) initWithView:(UIView*)gesturerView
{
    self = [super init];
    _transitionDuration = 1.0;
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [gesturerView addGestureRecognizer:gesture];
    return self;
}


- (CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}


- (double) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}


//Interactive and not percentage,
//Mean once the gesturer triggered, then it will going ahead.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    EZDEBUG(@"animation transition less parameter");
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
}

//Use the simplest animation to start my implementaiton.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    EZDEBUG(@"animation transition more parameter");
    // Add the toView to the container
    UIView* containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            fromView.alpha = 1.0;
        } else {
            // reset from- view to its original state
            [fromView removeFromSuperview];
            fromView.alpha = 1.0;
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}



- (void)handleGesture:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    EZDEBUG(@"handle gesturer scale:%f, state:%i, %i", gestureRecognizer.scale, gestureRecognizer.state, _operation);
    //BOOL shouldCompleteTransition = false;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startScale = gestureRecognizer.scale;
            _shouldCompleteTransition = false;
            // start an interactive transition!
            self.interactionInProgress = YES;
            
            // perform the required operation
            //if (_operation == CEInteractionOperationPop) {
            //    [_viewController.navigationController popViewControllerAnimated:YES];
            //} else {
            //    [_viewController dismissViewControllerAnimated:YES completion:nil];
            //}
            if(_pushBlock){
                _pushBlock(@(_operation));
            }
            break;
        case UIGestureRecognizerStateChanged: {
            // compute the current pinch fraction
            CGFloat fraction = 1.0 - gestureRecognizer.scale / _startScale;
            _shouldCompleteTransition = (fraction > 0.5);
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interactionInProgress = NO;
            if (!_shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            }
            else {
                [self finishInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

//From here I could get the snapShot of the view controller?
//Seems like so.
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    // when a push occurs, wire the interaction controller to the to- view controller
    /**
    if (AppDelegateAccessor.navigationControllerInteractionController) {
        [AppDelegateAccessor.navigationControllerInteractionController wireToViewController:toVC forOperation:CEInteractionOperationPop];
    }
    
    if (AppDelegateAccessor.navigationControllerAnimationController) {
        AppDelegateAccessor.navigationControllerAnimationController.reverse = operation == UINavigationControllerOperationPop;
    }
    **/
    EZDEBUG(@"from navigation");
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    EZDEBUG(@"animationController");
    // if we have an interaction controller - and it is currently in progress, return it
    /**
    return AppDelegateAccessor.navigationControllerInteractionController && AppDelegateAccessor.navigationControllerInteractionController.interactionInProgress ? AppDelegateAccessor.navigationControllerInteractionController : nil;
     **/
    return self;
}



- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    EZDEBUG(@"presented");
    _operation = EZInteractionOperationPresent;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //AppDelegateAccessor.settingsAnimationController.reverse = YES;
    EZDEBUG(@"dimissed");
    _operation = EZInteractionOperationDismiss;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    EZDEBUG(@"presentation");
    _operation = EZInteractionOperationPush;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    EZDEBUG(@"dismissal");
    _operation = EZInteractionOperationPop;
    return self;
}



@end
