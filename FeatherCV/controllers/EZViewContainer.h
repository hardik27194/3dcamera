//
//  EZViewContainer.h
//  Feather
//
//  Created by xietian on 13-10-7.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAppConstants.h"
//What's the purpose of this class
//It will act as a container.
//Maintain all the macro level view transition.
@interface EZViewContainer : UIViewController


@property (nonatomic, strong) UIView* contentView;
//It will get leftBar show off
@property (nonatomic, strong)UIViewController* leftView;

//Will show the right bar
@property (nonatomic, strong) UIViewController* rightView;

//When user pinch out will show this view.
@property (nonatomic, strong) UIViewController* zoomInView;

//Which one is the right thing to do?
//The simplest protocol would be, As long as I detect the zoom out
//And found the zoom out no more work. 
@property (nonatomic, strong) UIViewController* zoomOutView;

@property (nonatomic, strong) UIViewController* currentView;

- (void) showView:(UIViewController*)ctrl;

- (void) hideView:(UIViewController*)ctrl;

//@property (nonatomic, strong) UIViewController* initalView;

@end
