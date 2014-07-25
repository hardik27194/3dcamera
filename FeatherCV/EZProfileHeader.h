//
//  EZProfileHeader.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZShapeCover;
@interface EZProfileHeader : UIView

+ (EZProfileHeader*) createHeader;

@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) UILabel* middleInfo;

@property (nonatomic, strong) UILabel* bottomInfo;

@property (nonatomic, strong) UIImageView* avatar;

@property (nonatomic, strong) EZShapeCover* avatarCover;

@end
