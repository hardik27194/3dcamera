//
//  EZDrawAngle.h
//  3DCamera
//
//  Created by xietian on 14-9-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDrawable.h"

@interface EZDrawAngle : EZDrawable

@property (nonatomic, assign) CGFloat totalAngle;

@property (nonatomic, assign) CGPoint center;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat length;

@property (nonatomic, assign) CGFloat occupiedCount;

@property (nonatomic, strong) UIColor* occupiedColor;

@property (nonatomic, strong) UIColor* emptyColor;

@property (nonatomic, strong) UIColor* background;

@property (nonatomic, assign) CGRect frame;

+ (EZDrawAngle*) create:(CGRect)rect total:(CGFloat)total occupiedColor:(UIColor*)occupiedColor emptyColor:(UIColor*)emptyColor background:(UIColor*)background length:(CGFloat)length;

@end
