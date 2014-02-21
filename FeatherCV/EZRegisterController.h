//
//  EZRegisterController.h
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZRegisterController : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel* registerTitle;

@property (nonatomic, strong) IBOutlet UILabel* nameTitle;

@property (nonatomic, strong) IBOutlet UILabel* mobileTitle;

@property (nonatomic, strong) IBOutlet UILabel* passwordTitle;

@property (nonatomic, strong) IBOutlet UITextField* name;

@property (nonatomic, strong) IBOutlet UITextField* mobile;

@property (nonatomic, strong) IBOutlet UITextField* password;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) EZEventBlock completedBlock;

- (IBAction) registerClicked:(id)sender;

@end
