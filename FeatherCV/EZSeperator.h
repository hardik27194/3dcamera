//
//  EZSeperator.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZSeperator : UIView

@property (nonatomic, strong) UIView* leftBar;

@property (nonatomic, strong) UIView* rightBar;

@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, assign) CGFloat gap;

@property (nonatomic, strong) UIColor* color;

@end
