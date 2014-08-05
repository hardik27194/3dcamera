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

@property (nonatomic, strong) UIActivityIndicatorView* activity;

@property (nonatomic, strong) UIView* coverView;

@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, assign) NSTimer *timer;

@property (nonatomic, strong) UIButton* sendVerifyCode;

//How the focus are moving from one to another.
@property (nonatomic, strong) NSMutableDictionary* fieldMaps;
//@property (nonatomic, strong) EZEventBlock key

- (void) liftWithBottom:(CGFloat)deltaGap isSmall:(BOOL)small time:(CGFloat)timeval complete:(EZEventBlock)complete;

- (UIView*) createNavHeader:(NSString*)title;

- (void)timerTick:(NSTimer *)timer;

- (UIView*) createWrap:(CGRect)frame;

- (UILabel*) createPlaceHolder:(UITextField*)textField;

- (void) stopActivity;

- (void) startActivity;

@end
