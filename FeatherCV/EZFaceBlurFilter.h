//
//  EZ.h
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

//@class GPUImageGaussianBlurFilter;
@class EZColorGaussianFilter;
/** A Gaussian blur that preserves focus within a circular region
 */
@interface EZFaceBlurFilter : GPUImageFilterGroup
{
    EZColorGaussianFilter *blurFilter;
    GPUImageFilter *selectiveFocusFilter;
    BOOL hasOverriddenAspectRatio;
}

/** The radius of the circular area being excluded from the blur
 */
@property (readwrite, nonatomic) CGFloat excludeCircleRadius;
/** The center of the circular area being excluded from the blur
 */
@property (readwrite, nonatomic) CGPoint excludeCirclePoint;
/** The size of the area between the blurred portion and the clear circle
 */
@property (readwrite, nonatomic) CGFloat excludeBlurSize;
/** A multiplier for the size of the blur, ranging from 0.0 on up, with a default of 1.0
 */
@property (readwrite, nonatomic) CGFloat blurSize;
/** The aspect ratio of the image, used to adjust the circularity of the in-focus region. By default, this matches the image aspect ratio, but you can override this value.
 */
@property (readwrite, nonatomic) CGFloat realRatio;

@property (readwrite, nonatomic) CGFloat aspectRatio;

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

