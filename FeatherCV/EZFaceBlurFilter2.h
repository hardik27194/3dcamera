//
//  EZFaceBlurFilter2.h
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

@interface EZFaceBlurFilter2 : GPUImageFilter
{
    GLint vignetteCenterUniform, vignetteColorUniform, vignetteStartUniform, vignetteEndUniform;
}
// the center for the vignette in tex coords (defaults to 0.5, 0.5)
@property (nonatomic, readwrite) CGPoint vignetteCenter;

// The color to use for the Vignette (defaults to black)
@property (nonatomic, readwrite) GPUVector3 vignetteColor;

// The normalized distance from the center where the vignette effect starts. Default of 0.5.
@property (nonatomic, readwrite) CGFloat vignetteStart;

// The normalized distance from the center where the vignette effect ends. Default of 0.75.
@property (nonatomic, readwrite) CGFloat vignetteEnd;

@end

