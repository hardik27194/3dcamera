//
//  EZLoginController.h
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZLoginController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate>


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

@property (nonatomic, strong) UIView* seperator;

//-- Keyboard related functions
@property (nonatomic, strong) EZEventBlock keyboardRaiseHandler;

@property (nonatomic, strong) EZEventBlock keyboardHideHandler;

@property (nonatomic, strong) UITextField* currentFocused;

@property (nonatomic, assign) CGFloat prevKeyboard;
//@property (nonatomic, strong) EZEventBlock key

@end
