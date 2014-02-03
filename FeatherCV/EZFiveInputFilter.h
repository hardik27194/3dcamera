//
//  EZFiveInputFilter.h
//  FeatherCV
//
//  Created by xietian on 14-2-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZFourInputFilter.h"

@interface EZFiveInputFilter : EZFourInputFilter
{
    GLint filterFifthTextureCoordinateAttribute;
    GLint filterInputTextureUniform5;
    GPUImageRotationMode inputRotation5;
    GLuint filterSourceTexture5;
    CMTime fifthFrameTime;
    
    BOOL hasSetFourthTexture, hasReceivedFifthFrame, fifthFrameWasVideo;
    BOOL fifthFrameCheckDisabled;
    
    __unsafe_unretained id<GPUImageTextureDelegate> fifthTextureDelegate;
}

- (void)disableFifthFrameCheck;

- (void) resetUpdatedFrame;
@end
