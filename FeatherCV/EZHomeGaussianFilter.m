//
//  EZHomeGaussianFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeGaussianFilter.h"

NSString *const kGPUImageHomeGaussianBlurVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 uniform float blurRatio;
 varying vec2 textureCoordinate;
 varying float blurMultiplier[GAUSSIAN_SAMPLES];
 varying vec2 singleStepOffset;
 varying vec2 secSingleStepOffset;
 
 //varying vec2 secBlurCoordinates[GAUSSIAN_SAMPLES];
 //varying float originStep;
 //varying float secStep;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     
     // Calculate the positions for the blur
     int multiplier = 0;
     //vec2 blurStep;
     //vec2 secBlurStep;
     singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     secSingleStepOffset = vec2(texelWidthOffset/blurRatio, texelHeightOffset/blurRatio);
     for (int i = 0; i < GAUSSIAN_SAMPLES; i++)
     {
         multiplier = (i - ((GAUSSIAN_SAMPLES - 1) / 2));
         blurMultiplier[i] = float(multiplier);
     }
 }
 );

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageHomeGaussianBlurFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp float distanceNormalizationFactor;
 uniform highp float realRatio;
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp float blurMultiplier[GAUSSIAN_SAMPLES];
 varying highp vec2 singleStepOffset;
 varying highp vec2 secSingleStepOffset;
 
 lowp float sigmoid(highp float mixVal, highp float midVal)
 {
     highp float mixedVal = -(mixVal - midVal);
     return 1.0/(exp(mixedVal) + 1.0);
 }
 
 void main()
 {
     lowp vec4 sum1 = vec4(0.0);
     //lowp vec2 readXY = textureCoordinate.xy;
     highp vec2 secBlurCoordinates[GAUSSIAN_SAMPLES];
     highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
     for(int i = 0; i < GAUSSIAN_SAMPLES; i++)
     {
        blurCoordinates[i] = textureCoordinate.xy + blurMultiplier[i] * singleStepOffset;
        secBlurCoordinates[i] = textureCoordinate.xy + blurMultiplier[i] * secSingleStepOffset;
     }
     
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[0]) * 0.05;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[1]) * 0.09;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[2]) * 0.12;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[3]) * 0.15;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[4]) * 0.18;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[5]) * 0.15;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[6]) * 0.12;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[7]) * 0.09;
     sum1 += texture2D(inputImageTexture, secBlurCoordinates[8]) * 0.05;
     
     
     lowp vec4 centralColor;
     lowp float gaussianWeightTotal;
     lowp vec4 sum;
     lowp vec4 sampleColor;
     lowp float distanceFromCentralColor;
     lowp float gaussianWeight;
     
     centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     gaussianWeightTotal = 0.18;
     sum = centralColor * 0.18;
     
     highp float scaleFactor = distanceNormalizationFactor;
     highp float midVal = 3.0;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[0]);
     //distanceFromCentralColor = min(distance(centralColor, sampleColor) * distanceNormalizationFactor, 1.0);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[5]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[6]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[7]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     sampleColor = texture2D(inputImageTexture, blurCoordinates[8]);
     distanceFromCentralColor = sigmoid(distance(centralColor, sampleColor)*scaleFactor, midVal);
     //gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
     gaussianWeight = 1.0 - distanceFromCentralColor;
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     gl_FragColor = (sum / gaussianWeightTotal) * (1.0 - realRatio) + sum1 * realRatio;
 }
 );
#else
NSString *const kGPUImageGaussianBlurFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 void main()
 {
     vec4 sum = vec4(0.0);
     
     sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.05;
     sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.18;
     sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.05;
     
     gl_FragColor = sum;
 }
 );
#endif

@implementation EZHomeGaussianFilter


- (id) initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
             firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
              secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
            secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString {
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString ? firstStageVertexShaderString : kGPUImageHomeGaussianBlurVertexShaderString
                              firstStageFragmentShaderFromString:firstStageFragmentShaderString ? firstStageFragmentShaderString : kGPUImageHomeGaussianBlurFragmentShaderString
                               secondStageVertexShaderFromString:secondStageVertexShaderString ? secondStageVertexShaderString : kGPUImageHomeGaussianBlurVertexShaderString
                             secondStageFragmentShaderFromString:secondStageFragmentShaderString ? secondStageFragmentShaderString : kGPUImageHomeGaussianBlurFragmentShaderString])) {
        return nil;
    }
    firstDistanceNormalizationFactorUniform  = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    self.blurSize = 2.0;
    self.blurRatio = 0.5;
    return self;
}

- (id)init;
{
    return [self initWithFirstStageVertexShaderFromString:nil
                       firstStageFragmentShaderFromString:nil
                        secondStageVertexShaderFromString:nil
                      secondStageFragmentShaderFromString:nil];
}

#pragma mark -
#pragma mark Accessors
- (void)setBlurRatio:(CGFloat)newValue;
{
    _blurRatio = newValue;
    [self setFloat:_blurRatio forUniformName:@"blurRatio"];
}


- (void)setBlurSize:(CGFloat)newValue;
{
    _blurSize = newValue;
    
    _verticalTexelSpacing = _blurSize;
    _horizontalTexelSpacing = _blurSize;
    
    [self setupFilterForSize:[self sizeOfFBO]];
}

- (void)setDistanceNormalizationFactor:(CGFloat)newValue
{
    _distanceNormalizationFactor = newValue;
    [self setFloat:newValue
        forUniform:firstDistanceNormalizationFactorUniform
           program:filterProgram];
}

- (void) setRealRatio:(CGFloat)realRatio
{
    _realRatio = realRatio;
    [self setFloat:_realRatio forUniformName:@"realRatio"];
}

@end
