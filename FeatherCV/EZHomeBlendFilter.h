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
#import "EZHomeLineBiFilter.h"
#import "EZSkinBrighter.h"

@class EZFourInputFilter;
@interface EZHomeBlendFilter : GPUImageFilterGroup
{
    BOOL hasOverriddenAspectRatio;
}

@property (nonatomic, strong) EZSkinBrighter* skinBrighter;
@property (nonatomic, strong) EZHomeBiBlur* blurFilter;
@property (nonatomic, strong) EZHomeLineBiFilter* smallBlurFilter;
@property (nonatomic, strong) EZHomeEdgeFilter* edgeFilter;
@property (nonatomic, strong) GPUImageGaussianBlurFilter* edgeBlurFilter;
@property (nonatomic, strong) EZFourInputFilter* combineFilter;

@property (nonatomic, assign) CGFloat blurRatio;
@property (nonatomic, assign) CGFloat edgeRatio;
@property (readwrite, nonatomic) NSArray* skinColors;

@property (nonatomic, assign) int imageMode;

@end
