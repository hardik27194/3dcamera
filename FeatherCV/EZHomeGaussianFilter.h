//
//  EZHomeGaussianFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

@interface EZHomeGaussianFilter : GPUImageTwoPassTextureSamplingFilter
{
    CGFloat firstDistanceNormalizationFactorUniform;
}
/** A multiplier for the blur size, ranging from 0.0 on up, with a default of 1.0
 */
@property (readwrite, nonatomic) CGFloat blurSize;

//What's the blurSize for the smaller object?
@property (readwrite, nonatomic) CGFloat blurRatio;

@property (readwrite, nonatomic) CGFloat realRatio;

// A normalization factor for the distance between central color and sample color.
@property(nonatomic, readwrite) CGFloat distanceNormalizationFactor;

@end
