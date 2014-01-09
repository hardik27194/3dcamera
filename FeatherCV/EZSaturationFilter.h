//
//  EZSaturationFilter.h
//  FeatherCV
//
//  Created by xietian on 13-12-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "GPUImageFilter.h"

@interface EZSaturationFilter : GPUImageFilter

/**
 uniform highp float lowRed;
 uniform highp float midYellow;
 uniform highp float highBlue;
 
 uniform highp float yellowRedDegree;
 uniform highp float yellowBlueDegree;
 **/

@property (readwrite, nonatomic) CGFloat lowRed;
@property (readwrite, nonatomic) CGFloat midYellow;
@property (readwrite, nonatomic) CGFloat highBlue;

@property (readwrite, nonatomic) CGFloat yellowRedDegree;
@property (readwrite, nonatomic) CGFloat yellowBlueDegree;

@end
