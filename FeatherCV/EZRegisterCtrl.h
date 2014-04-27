//
//  EZRegisterCtrl.h
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"

@class EZClickImage;

@interface EZRegisterCtrl : EZKeyboardController<UIActionSheetDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UILabel* titleInfo;
//@property (nonatomic, strong) UILabel* introduction;
@property (nonatomic, strong) UITextView* introduction;

@property (nonatomic, strong) UITextField* name;

@property (nonatomic, strong) UILabel* namePlaceHolder;

@property (nonatomic, strong) UITextField* mobileField;

@property (nonatomic, strong) UILabel* mobilePlaceHolder;

@property (nonatomic, strong) UITextField* passwordField;

@property (nonatomic, strong) UILabel* passwordPlaceHolder;

@property (nonatomic, strong) UIButton* loginButton;

@property (nonatomic, strong) UIButton* passwordButton;

@property (nonatomic, strong) UIButton* registerButton;



@property (nonatomic, strong) UIButton* confirmCode;

@property (nonatomic, strong) UIView* seperator;

@property (nonatomic, strong) EZClickImage* uploadAvatar;

@property (nonatomic, strong) NSString* avatarURL;

@property (nonatomic, assign) BOOL uploadingAvatar;

@property (nonatomic, strong) EZEventBlock registerBlock;

@property (nonatomic, strong) UIView* originalView;

@property (nonatomic, strong) UIPageControl* pageControl;

@property (nonatomic, strong) UIScrollView* scrollContainer;

@property (nonatomic, strong) UIView* smsView;




//@property (nonatomic, strong) UIPageControl* pageControl;


//@property (nonatomic, strong) UIImage* avatarImage;

@end
