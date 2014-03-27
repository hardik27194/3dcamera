//
//  EZ.h
//  FeatherCV
//
//  Created by xietian on 14-3-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EZClickImage;
@class EZPerson;
@interface EZPersonDetail : UIViewController<UIActionSheetDelegate>

@property (nonatomic, strong) UILabel* titleInfo;

@property (nonatomic, strong) UILabel* mobile;

@property (nonatomic, strong) EZPerson* person;

@property (nonatomic, strong) EZClickImage* uploadAvatar;

@property (nonatomic, strong) NSString* avatarURL;

@property (nonatomic, strong) EZClickImage* quitButton;

@property (nonatomic, strong) UIButton* quitUser;

- (id) initWithPerson:(EZPerson*)person;

@end
