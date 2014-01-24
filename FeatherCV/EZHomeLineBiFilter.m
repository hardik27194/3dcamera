//
//  EZHomeLineBiFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-22.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeLineBiFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

NSString *const kGPUImageHomeLineBiBlurVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 varying vec2 textureCoordinate2;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     // Calculate the positions for the blur
     int multiplier = 0;
     vec2 blurStep;
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     
     for (int i = 0; i < GAUSSIAN_SAMPLES; i++)
     {
         multiplier = (i - ((GAUSSIAN_SAMPLES - 1) / 2));
         // Blur in x (horizontal)
         blurStep = float(multiplier) * singleStepOffset;
         blurCoordinates[i] = inputTextureCoordinate.xy + blurStep;
     }
 }
 );


NSString *const kGPUImageHomeLineBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform mediump float distanceNormalizationFactor;
 uniform lowp int imageMode;
 const lowp vec3 skinColor = vec3(0.753, 0.473, 0.332);
 
 lowp float sigmoid(highp float mixVal, highp float midVal)
 {
     highp float mixedVal = -(mixVal - midVal)*1.5;
     return 1.0/(exp(mixedVal) + 1.0);
 }
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.7){
         fd = fd * fd * fd;
     }else{
         fd = 1.0/(exp(-fd * 2.0) + 1.0);
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     lowp vec4 centralColor;
     lowp float gaussianWeightTotal;
     lowp vec4 sum;
     lowp vec4 sampleColor;
     lowp float distanceFromCentralColor;
     lowp float gaussianWeight;
     lowp vec4 centralLine = texture2D(inputImageTexture2, blurCoordinates[4]);
     lowp float otherRatio = 1.0 - centralLine.r;
     
     centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     gaussianWeightTotal = 0.18;
     sum = centralColor * 0.18;
     
     lowp float orgDist = 1.0 - calcHue(centralColor);
     highp float scaleFactor = distanceNormalizationFactor;
     highp float midVal = 3.0;
     
     lowp float sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[0]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[0]);
     lowp float sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[1]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[2]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[3]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[5]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[5]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[6]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[6]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[7]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[7]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleRatio = 1.0 - texture2D(inputImageTexture2, blurCoordinates[8]).r;
     sampleColor = texture2D(inputImageTexture, blurCoordinates[8]);
     sampleDist = calcHue(sampleColor);
     //distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeight = otherRatio * sampleRatio * (1.0 - sampleDist) * orgDist;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     if(imageMode == 0){
         gl_FragColor = sum / gaussianWeightTotal;
     }else{
         gl_FragColor = centralLine;
     }
     //gl_FragColor = lineColor;
     //gl_FragColor = centralColor;
 }
 );
#else
NSString *const kGPUImageBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform float distanceNormalizationFactor;
 
 void main()
 {
     vec4 centralColor;
     float gaussianWeightTotal;
     vec4 sum;
     vec4 sampleColor;
     float distanceFromCentralColor;
     float gaussianWeight;
     
     centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     gaussianWeightTotal = 0.18;
     sum = centralColor * 0.18;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[0]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[5]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[6]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[7]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[8]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     gl_FragColor = sum / gaussianWeightTotal;
 }
 );
#endif

@implementation EZHomeLineBiFilter

@synthesize distanceNormalizationFactor = _distanceNormalizationFactor;

- (id)init;
{
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:kGPUImageHomeLineBiBlurVertexShaderString
                              firstStageFragmentShaderFromString:kGPUImageHomeLineBilateralFilterFragmentShaderString
                               secondStageVertexShaderFromString:kGPUImageHomeLineBiBlurVertexShaderString
                             secondStageFragmentShaderFromString:kGPUImageHomeLineBilateralFilterFragmentShaderString])) {
        return nil;
    }
    
    firstDistanceNormalizationFactorUniform  = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    secondDistanceNormalizationFactorUniform = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    
    self.blurSize = 4.0;
    self.distanceNormalizationFactor = 8.0;
    
    inputRotation2 = kGPUImageNoRotation;
    
    hasSetFirstTexture = NO;
    
    hasReceivedFirstFrame = NO;
    hasReceivedSecondFrame = NO;
    firstFrameWasVideo = NO;
    secondFrameWasVideo = NO;
    firstFrameCheckDisabled = NO;
    secondFrameCheckDisabled = NO;
    
    firstFrameTime = kCMTimeInvalid;
    secondFrameTime = kCMTimeInvalid;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterSecondTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate2"];
        
        filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        glEnableVertexAttribArray(filterSecondTextureCoordinateAttribute);
    });
    
    return self;
}


#pragma mark -
#pragma mark Accessors

- (void)setDistanceNormalizationFactor:(CGFloat)newValue
{
    _distanceNormalizationFactor = newValue;
    
    [self setFloat:newValue
        forUniform:firstDistanceNormalizationFactorUniform
           program:filterProgram];
    
    [self setFloat:newValue
        forUniform:secondDistanceNormalizationFactorUniform
           program:secondFilterProgram];
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate2"];
}

- (void)disableFirstFrameCheck;
{
    firstFrameCheckDisabled = YES;
}

- (void)disableSecondFrameCheck;
{
    secondFrameCheckDisabled = YES;
}

#pragma mark -
#pragma mark Rendering
- (void)renderToTextureWithVerticesSuper:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
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
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}



- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    NSLog(@"Bi Guassian pass:%i", currentlyReceivingMonochromeInput);
    // This assumes that any two-pass filter that says it desires monochrome input is using the first pass for a luminance conversion, which can be dropped
    if (!currentlyReceivingMonochromeInput)
    {
        EZDEBUG(@"Home Bi Blur, call super");
        // Run the first stage of the two-pass filter
        [self renderToTextureWithVerticesSuper:vertices textureCoordinates:textureCoordinates sourceTexture:sourceTexture];
    }
    
    // Run the second stage of the two-pass filter
    [self setSecondFilterFBO];
    
    [GPUImageContext setActiveShaderProgram:secondFilterProgram];
    [self setUniformsForProgramAtIndex:1];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (!currentlyReceivingMonochromeInput)
    {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, outputTexture);
        
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
        glUniform1i(filterInputTextureUniform2, 4);
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        glVertexAttribPointer(secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:kGPUImageNoRotation]);
    }
    else
    {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, sourceTexture);
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
        glUniform1i(filterInputTextureUniform2, 4);
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        
        //glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
        glVertexAttribPointer(secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    }
    
	glUniform1i(secondFilterInputTextureUniform, 3);
    glVertexAttribPointer(secondFilterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Release the first FBO early
    if (shouldConserveMemoryForNextFrame)
    {
        [firstTextureDelegate textureNoLongerNeededForTarget:self];
        
        glDeleteFramebuffers(1, &filterFramebuffer);
        filterFramebuffer = 0;
        
        if (outputTexture)
        {
            glDeleteTextures(1, &outputTexture);
            outputTexture = 0;
        }
        
        shouldConserveMemoryForNextFrame = NO;
    }
    
}

- (void)releaseInputTexturesIfNeeded;
{
    if (shouldConserveMemoryForNextFrame)
    {
        [firstTextureDelegate textureNoLongerNeededForTarget:self];
        [secondTextureDelegate textureNoLongerNeededForTarget:self];
        shouldConserveMemoryForNextFrame = NO;
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
    if (hasSetFirstTexture)
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
    else
    {
        filterSourceTexture2 = newInputTexture;
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
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else
    {
        inputRotation2 = newInputRotation;
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
    else
    {
        rotationToCheck = inputRotation2;
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
    if (hasReceivedFirstFrame && hasReceivedSecondFrame)
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
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(secondFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        hasReceivedSecondFrame = YES;
        secondFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
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
    if (hasReceivedFirstFrame && hasReceivedSecondFrame)
    {
        [super newFrameReadyAtTime:firstFrameTime atIndex:0]; // Bugfix when trying to record: always use time from first input
        hasReceivedFirstFrame = NO;
        hasReceivedSecondFrame = NO;
    }
}

- (void)setTextureDelegate:(id<GPUImageTextureDelegate>)newTextureDelegate atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstTextureDelegate = newTextureDelegate;
    }
    else
    {
        secondTextureDelegate = newTextureDelegate;
    }
}

- (void) setImageMode:(int)imageMode
{
    _imageMode = imageMode;
    [self setInteger:imageMode forUniformName:@"imageMode"];
}

@end
