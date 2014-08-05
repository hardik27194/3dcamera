//
//  EZRegisterPage.h
//  BabyCare
//
//  Created by xietian on 14-8-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZKeyboardController.h"

@interface EZRegisterCtrl :  EZKeyboardController<UIScrollViewDelegate>

@property (nonatomic, strong) UITextField* nickName;

@property (nonatomic, strong) UITextField* mobileNumber;

@property (nonatomic, strong) UITextField* mobileSmsCode;

@property (nonatomic, strong) UITextField* password;

@property (nonatomic, strong) UITextField* confirmPassword;

@property (nonatomic, strong) UIButton* sendSmsCode;

@property (nonatomic, strong) UILabel* countDown;

@property (nonatomic, assign) NSInteger smsCodeCounter;

@property (nonatomic, strong) UIButton* sendBtn;

@end
