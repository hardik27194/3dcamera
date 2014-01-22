//
//  EZHomeLineBiFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-22.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageFilter.h"
#import "GPUImage.h"

@interface EZHomeLineBiFilter : GPUImageGaussianBlurFilter
{
    CGFloat firstDistanceNormalizationFactorUniform;
    CGFloat secondDistanceNormalizationFactorUniform;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    GPUImageRotationMode inputRotation2;
    GLuint filterSourceTexture2;
    CMTime firstFrameTime, secondFrameTime;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, hasReceivedSecondFrame, firstFrameWasVideo, secondFrameWasVideo;
    BOOL firstFrameCheckDisabled, secondFrameCheckDisabled;
    
    __unsafe_unretained id<GPUImageTextureDelegate> secondTextureDelegate;
}
// A normalization factor for the distance between central color and sample color.
@property(nonatomic, readwrite) CGFloat distanceNormalizationFactor;

@property (nonatomic, assign) int imageMode;

@end

