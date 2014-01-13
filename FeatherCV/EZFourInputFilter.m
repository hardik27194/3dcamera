//
//  EZFourInputFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZFourInputFilter.h"


NSString *const kGPUImageFourInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 attribute vec4 inputTextureCoordinate4;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 varying vec2 textureCoordinate4;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     textureCoordinate3 = inputTextureCoordinate3.xy;
     textureCoordinate4 = inputTextureCoordinate4.xy;
 }
 );

@implementation EZFourInputFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kGPUImageFourInputTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    inputRotation4 = kGPUImageNoRotation;
    
    hasSetThirdTexture = NO;
    
    hasReceivedFourthFrame = NO;
    fourthFrameWasVideo = NO;
    fourthFrameCheckDisabled = NO;
    
    fourthFrameTime = kCMTimeInvalid;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterFourthTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate4"];
        
        filterInputTextureUniform4 = [filterProgram uniformIndex:@"inputImageTexture4"]; // This does assume a name of "inputImageTexture3" for the third input texture in the fragment shader
        glEnableVertexAttribArray(filterFourthTextureCoordinateAttribute);
    });
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate4"];
}

- (void)disableThirdFrameCheck;
{
    fourthFrameCheckDisabled = YES;
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    [self setFilterFBO];
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, sourceTexture);
	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, filterSourceTexture3);
    glUniform1i(filterInputTextureUniform3, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, filterSourceTexture4);
    glUniform1i(filterInputTextureUniform4, 5);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    glVertexAttribPointer(filterThirdTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation3]);
    glVertexAttribPointer(filterFourthTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation4]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)releaseInputTexturesIfNeeded;
{
    if (shouldConserveMemoryForNextFrame)
    {
        [firstTextureDelegate textureNoLongerNeededForTarget:self];
        [secondTextureDelegate textureNoLongerNeededForTarget:self];
        [thirdTextureDelegate textureNoLongerNeededForTarget:self];
        [fourthTextureDelegate textureNoLongerNeededForTarget:self];
        shouldConserveMemoryForNextFrame = NO;
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
    if(hasSetThirdTexture){
        return 3;
    }
    else if (hasSetSecondTexture)
    {
        return 2;
    }
    else if (hasSetFirstTexture)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        filterSourceTexture = newInputTexture;
        hasSetFirstTexture = YES;
    }
    else if (textureIndex == 1)
    {
        filterSourceTexture2 = newInputTexture;
        hasSetSecondTexture = YES;
    }
    else if(textureIndex == 2)
    {
        filterSourceTexture3 = newInputTexture;
        hasSetThirdTexture = YES;
    }else {
        filterSourceTexture4 = newInputTexture;
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
        
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFirstTexture = NO;
        }
    }
    else if (textureIndex == 1)
    {
        //This is the fix 
        //[super setInputSize:newSize atIndex:textureIndex];
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSecondTexture = NO;
        }
    }
    else if (textureIndex == 2)
    {
        if(CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetThirdTexture = NO;
        }
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else if (textureIndex == 1)
    {
        inputRotation2 = newInputRotation;
    }
    else if(textureIndex == 2)
    {
        inputRotation3 = newInputRotation;
    }
    else
    {
        inputRotation4 = newInputRotation;
    }
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    GPUImageRotationMode rotationToCheck;
    if (textureIndex == 0)
    {
        rotationToCheck = inputRotation;
    }
    else if (textureIndex == 1)
    {
        rotationToCheck = inputRotation2;
    }
    else if (textureIndex == 2)
    {
        rotationToCheck = inputRotation3;
    }else
    {
        rotationToCheck = inputRotation4;
    }
    
    if (GPUImageRotationSwapsWidthAndHeight(rotationToCheck))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    outputTextureRetainCount = [targets count];
    
    // You can set up infinite update loops, so this helps to short circuit them
    if (hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame)
    {
        return;
    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;
    
    if (textureIndex == 0)
    {
        hasReceivedFirstFrame = YES;
        firstFrameTime = frameTime;
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled){
            hasReceivedFourthFrame = YES;
        }
        
        //I don't understand what's the meaning of this.
        //Let's check the 2 input frame see what's the difference.
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(secondFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 1)
    {
        hasReceivedSecondFrame = YES;
        secondFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if(textureIndex == 2)
    {
        hasReceivedThirdFrame = YES;
        thirdFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if(fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        hasReceivedFourthFrame = YES;
        fourthFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if(thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }

    }
    
    // || (hasReceivedFirstFrame && secondFrameCheckDisabled) || (hasReceivedSecondFrame && firstFrameCheckDisabled)
    if (hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame)
    {
        outputTextureRetainCount = [targets count];
        
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation] sourceTexture:filterSourceTexture];
        
        [self informTargetsAboutNewFrameAtTime:frameTime];
        
        hasReceivedFirstFrame = NO;
        hasReceivedSecondFrame = NO;
        hasReceivedThirdFrame = NO;
        hasReceivedFourthFrame = NO;
    }
}

- (void)setTextureDelegate:(id<GPUImageTextureDelegate>)newTextureDelegate atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstTextureDelegate = newTextureDelegate;
    }
    else if (textureIndex == 1)
    {
        secondTextureDelegate = newTextureDelegate;
    }
    else if(textureIndex == 2)
    {
        thirdTextureDelegate = newTextureDelegate;
    }else
    {
        fourthTextureDelegate = newTextureDelegate;
    }
}

@end