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
#import <GPUImageThreeInputFilter.h>
#import "EZHomeEdgeFilter.h"
@class EZFourInputFilter;
@interface EZHomeBlendFilter : GPUImageFilterGroup
{
    BOOL hasOverriddenAspectRatio;
}

@property (nonatomic, strong) EZHomeBiBlur* blurFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* smallBlurFilter;
@property (nonatomic, strong) EZHomeEdgeFilter* edgeFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* edgeBlurFilter;
@property (nonatomic, strong) GPUImageThreeInputFilter* combineFilter;

@property (nonatomic, assign) CGFloat blurRatio;
@property (nonatomic, assign) CGFloat edgeRatio;

@end
