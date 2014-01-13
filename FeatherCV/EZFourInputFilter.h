//
//  EZFourInputFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImageThreeInputFilter.h>

extern NSString *const kGPUImageFourthInputTextureVertexShaderString;

@interface EZFourInputFilter : GPUImageThreeInputFilter
{
    GLint filterFourthTextureCoordinateAttribute;
    GLint filterInputTextureUniform4;
    GPUImageRotationMode inputRotation4;
    GLuint filterSourceTexture4;
    CMTime fourthFrameTime;
    
    BOOL hasSetThirdTexture, hasReceivedFourthFrame, fourthFrameWasVideo;
    BOOL fourthFrameCheckDisabled;
    
    __unsafe_unretained id<GPUImageTextureDelegate> fourthTextureDelegate;
}

- (void)disableFourthFrameCheck;

- (void) resetUpdatedFrame;
@end
