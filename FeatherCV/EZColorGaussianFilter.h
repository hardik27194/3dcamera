//
//  EZ.h
//  FeatherCV
//
//  Created by xietian on 14-1-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@interface EZColorGaussianFilter: GPUImageTwoPassTextureSamplingFilter

/** A multiplier for the blur size, ranging from 0.0 on up, with a default of 1.0
 */
@property (readwrite, nonatomic) CGFloat blurSize;


@end
