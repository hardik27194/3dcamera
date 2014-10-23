//
//  EZPersonDetail.h
//  3DCamera
//
//  Created by xietian on 14-10-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"

@class EZPerson;
@interface EZPersonDetail : EZKeyboardController

@property (nonatomic, strong) EZPerson* person;

@property (nonatomic, strong) UITextField* nickName;

@property (nonatomic, strong) UITextField* mobileNumber;

@property (nonatomic, strong) UITextField* password;

@property (nonatomic, strong) UIButton* sendBtn;

@property (nonatomic, strong) UIButton* quitBtn;

@property (nonatomic, assign) BOOL isEditable;

- (id) initWithPerson:(EZPerson*)person;

@end
