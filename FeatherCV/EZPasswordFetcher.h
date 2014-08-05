//
//  EZPasswordFetcher.h
//  FeatherCV
//
//  Created by xietian on 14-6-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"

@interface EZPasswordFetcher : EZKeyboardController<UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField* mobileNumber;

@property (nonatomic, strong) UITextField* mobileSmsCode;

@property (nonatomic, strong) UITextField* password;

@property (nonatomic, strong) UITextField* confirmPassword;

@property (nonatomic, strong) UIButton* sendSmsCode;

@property (nonatomic, strong) UILabel* countDown;

@property (nonatomic, assign) NSInteger smsCodeCounter;

@property (nonatomic, strong) UIButton* sendBtn;

@end
