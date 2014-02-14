//
//  EZ.m
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeBiBlur.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageHomeBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform mediump float distanceNormalizationFactor;
 
 lowp float sigmoid(highp float mixVal, highp float midVal)
 {
     highp float mixedVal = -(mixVal - midVal) * 4.0;
     return 1.0/(exp(mixedVal) + 1.0);
 }
 
 void main()
 {
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
     
     gl_FragColor = sum / gaussianWeightTotal;
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

@implementation EZHomeBiBlur

@synthesize distanceNormalizationFactor = _distanceNormalizationFactor;

- (id)init;
{
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:nil
                              firstStageFragmentShaderFromString:kGPUImageHomeBilateralFilterFragmentShaderString
                               secondStageVertexShaderFromString:nil
                             secondStageFragmentShaderFromString:kGPUImageHomeBilateralFilterFragmentShaderString])) {
        return nil;
    }
    
    firstDistanceNormalizationFactorUniform  = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    secondDistanceNormalizationFactorUniform = [filterProgram uniformIndex:@"distanceNormalizationFactor"];
    
    self.blurSize = 4.0;
    self.distanceNormalizationFactor = 8.0;
    
    
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

@end
