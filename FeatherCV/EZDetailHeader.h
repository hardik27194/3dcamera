//
//  EZDetailHeader.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZDetailHeader : UIView

+ (EZDetailHeader*) createDetailHeader;

@property (nonatomic, strong) UIImageView* icon;

@property (nonatomic, strong) UILabel* detailName;

@property (nonatomic, strong) UILabel* countInfo;

@property (nonatomic, strong) UILabel* countUnit;

@property (nonatomic, strong) UIImageView* graph;

@end
