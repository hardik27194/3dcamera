//
//  EZRegisterController.h
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EZClickImage.h"

@interface EZRegisterController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UILabel* registerTitle;

@property (nonatomic, strong) IBOutlet UILabel* registerReason;

@property (nonatomic, strong) IBOutlet UILabel* nameTitle;

@property (nonatomic, strong) IBOutlet UILabel* mobileTitle;

@property (nonatomic, strong) IBOutlet UILabel* passwordTitle;

@property (nonatomic, strong) IBOutlet UITextField* name;

@property (nonatomic, strong) IBOutlet UITextField* mobile;

@property (nonatomic, strong) IBOutlet UITextField* password;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) EZEventBlock completedBlock;

@property (nonatomic, strong) EZEventBlock dismissBlock;

@property (nonatomic, strong) EZClickImage* uploadAvatar;

//I will have a ErrorInfo definition in this code.
//Not all block need this detail information.
@property (nonatomic, strong) EZEventBlock cancelBlock;

- (IBAction) registerClicked:(id)sender;

@end
