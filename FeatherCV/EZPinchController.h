//
//  EZPinchController.h
//  TransitionsDemo
//
//  Created by xietian on 14-6-24.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "EZConstants.h"


typedef NS_ENUM(NSInteger, EZInteractionOperation) {
    /**
     Indicates that the interaction controller should start a navigation controller 'pop' navigation.
     */
    EZInteractionOperationPop,
    EZInteractionOperationPush,
    /**
     Indicates that the interaction controller should initiate a modal 'dismiss'.
     */
    EZInteractionOperationPresent,
    EZInteractionOperationDismiss,
    /**
     Indicates that the interaction controller should navigate between tabs.
     */
    CEInteractionOperationTab
};


@interface EZPinchController : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

- (id) initWithView:(UIView*)gesturerView;

@property (nonatomic, assign) EZInteractionOperation operation;

@property (nonatomic, strong) EZEventBlock pushBlock;

@property (nonatomic, assign) BOOL interactionInProgress;

@property (nonatomic, assign) CGFloat startScale;

@property (nonatomic, assign) BOOL shouldCompleteTransition;

@property (nonatomic, assign) CGFloat transitionDuration;

@end
