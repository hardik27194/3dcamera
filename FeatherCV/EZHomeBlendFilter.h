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

@property (nonatomic, strong) GPUImageBilateralFilter* blurFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* smallBlurFilter;
@property (nonatomic, strong) GPUImagePrewittEdgeDetectionFilter* edgeFilter;
@property (nonatomic, strong) GPUImageFilter* combineFilter;


@end
