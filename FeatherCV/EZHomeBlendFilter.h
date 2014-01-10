//
//  EZHomeBlendFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>
#import "EZHomeBiBlur.h"

@interface EZHomeBlendFilter : GPUImageFilterGroup
{
    CGFloat firstDistanceNormalizationFactorUniform;
    CGFloat secondDistanceNormalizationFactorUniform;
    BOOL hasOverriddenAspectRatio;
}



@property (readwrite, nonatomic) CGFloat realRatio;

@property (nonatomic, strong) GPUImageGaussianBlurFilter *gaussianBlur;

@property (nonatomic, strong) GPUImageTwoInputFilter* twoInputFilter;

@property (nonatomic, strong) EZHomeBiBlur *blurFilter;

@end
