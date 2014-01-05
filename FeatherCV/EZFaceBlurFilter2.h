//
//  EZ.h
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>
#import "EZColorGaussianFilter.h"

@class GPUImageGaussianBlurFilter;

/** A Gaussian blur that preserves focus within a circular region
 */
@interface EZFaceBlurFilter2 : GPUImageFilterGroup
{
    EZColorGaussianFilter *blurFilter;
    GPUImageFilter *selectiveFocusFilter;
    GPUVector3 centerColors;
    BOOL hasOverriddenAspectRatio;
}


@property (readwrite, nonatomic) CGFloat blurSize;
/** The aspect ratio of the image, used to adjust the circularity of the in-focus region. By default, this matches the image aspect ratio, but you can override this value.
 */
@property (readwrite, nonatomic) CGFloat realRatio;

@property (readwrite, nonatomic) CGFloat aspectRatio;

@property (readwrite, nonatomic) NSArray* skinColors;

@property (readwrite, nonatomic) CGFloat exponentChange;

@end
