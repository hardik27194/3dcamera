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
    BOOL hasOverriddenAspectRatio;
}

@property (nonatomic, strong) EZHomeBiBlur* blurFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* smallBlurFilter;
@property (nonatomic, strong) GPUImagePrewittEdgeDetectionFilter* edgeFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* edgeBlurFilter;
@property (nonatomic, strong) GPUImageFilter* combineFilter;

@property (nonatomic, assign) CGFloat blurRatio;

@end
