//
//  EZColorBrighter.h
//  FeatherCV
//
//  Created by xietian on 14-1-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageFilter.h"

@interface EZColorBrighter : GPUImageFilter

@property (readwrite, nonatomic) CGFloat redEnhanceLevel;
@property (readwrite, nonatomic) CGFloat redRatio;


@property (readwrite, nonatomic) CGFloat blueEnhanceLevel;
@property (readwrite, nonatomic) CGFloat blueRatio;
@property (readwrite, nonatomic) CGFloat blueLimit;

@end
