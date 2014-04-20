//
//  EZKeyboardController.h
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZCameraNaviAnimation.h"

@interface EZKeyboardController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

//-- Keyboard related functions
@property (nonatomic, strong) EZEventBlock keyboardRaiseHandler;

@property (nonatomic, strong) EZEventBlock keyboardHideHandler;

@property (nonatomic, strong) UITextField* currentFocused;

@property (nonatomic, assign) CGFloat prevKeyboard;

@property (nonatomic, strong) EZCameraNaviAnimation* cameraNaviAnim;

@property (nonatomic, assign) BOOL haveDelta;

@property (nonatomic, assign) CGFloat smallGap;
//@property (nonatomic, strong) EZEventBlock key

- (void) liftWithBottom:(CGFloat)deltaGap isSmall:(BOOL)small time:(CGFloat)timeval complete:(EZEventBlock)complete;


- (UIView*) createWrap:(CGRect)frame;

- (UILabel*) createPlaceHolder:(UITextField*)textField;

@end
