//
//  EZLoginController.h
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZKeyboardController.h"

@interface EZLoginController : EZKeyboardController<UIActionSheetDelegate>


@property (nonatomic, strong) UILabel* titleInfo;

//@property (nonatomic, strong) UILabel* introduction;
@property (nonatomic, strong) UITextView* introduction;

@property (nonatomic, strong) UITextField* mobileField;

@property (nonatomic, strong) UILabel* mobilePlaceHolder;

@property (nonatomic, strong) UITextField* passwordField;

@property (nonatomic, strong) UILabel* passwordPlaceHolder;

@property (nonatomic, strong) UIButton* loginButton;

@property (nonatomic, strong) UIButton* passwordButton;

@property (nonatomic, strong) UIButton* registerButton;

@property (nonatomic, strong) UIButton* sendVerifyCode;

@property (nonatomic, strong) UIView* seperator;


@end
