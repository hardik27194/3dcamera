//
//  EZ.m
//  FeatherCV
//
//  Created by xietian on 14-1-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZColorGaussianFilter.h"

NSString *const kGPUImageGaussianBlurVertexShaderString0 = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 const int GAUSSIAN_SAMPLES = 9;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 textureCoordinate;
 varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     
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

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageGaussianBlurFragmentShaderString0 = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 const lowp float gapVal = 0.15;
 const lowp float revGapVal = 0.85;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 

 lowp float colorDistance(lowp vec4 dest, lowp vec4 src)
{
    highp vec4 delta = src - dest;
    return sqrt(dot(delta, delta)/dot(src, src));
}
 
 
 lowp vec4 colorMix(lowp vec4 src, lowp vec4 dest, lowp float mixVal){
     lowp float finalMix = 1.0 - mixVal;
     //if(finalMix < revGapVal){
     finalMix = ;
     //}
     return src * (1.0 - finalMix) + dest * finalMix;
 }
 /**
 lowp float calcHue(highp vec4 rawcolor, highp float orghue)
 {
     const lowp vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
     const lowp vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
     const lowp vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
     
     highp float   I      = dot (rawcolor, kRGBToI);
     highp float   Q      = dot (rawcolor, kRGBToQ);
     highp float hue = atan(Q, I);
     return abs((hue - orghue)/(2.0 * 3.1415926535));
 }
 **/
 void main()
 {
     lowp vec4 sum = vec4(0.0);

     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     

     lowp vec4 color0 = texture2D(inputImageTexture, blurCoordinates[0]);
     lowp vec4 color1 = texture2D(inputImageTexture, blurCoordinates[1]);
     lowp vec4 color2 = texture2D(inputImageTexture, blurCoordinates[2]);
     lowp vec4 color3 = texture2D(inputImageTexture, blurCoordinates[3]);
     lowp vec4 color4 = texture2D(inputImageTexture, blurCoordinates[4]);
     lowp vec4 color5 = texture2D(inputImageTexture, blurCoordinates[5]);
     lowp vec4 color6 = texture2D(inputImageTexture, blurCoordinates[6]);
     lowp vec4 color7 = texture2D(inputImageTexture, blurCoordinates[7]);
     lowp vec4 color8 = texture2D(inputImageTexture, blurCoordinates[8]);
     
     lowp float hue0 = colorDistance(color0, sharpImageColor);
     lowp float hue1 = colorDistance(color1, sharpImageColor);
     lowp float hue2 = colorDistance(color2, sharpImageColor);
     lowp float hue3 = colorDistance(color3, sharpImageColor);
     lowp float hue4 = colorDistance(color4, sharpImageColor);
     lowp float hue5 = colorDistance(color5, sharpImageColor);
     lowp float hue6 = colorDistance(color6, sharpImageColor);
     lowp float hue7 = colorDistance(color7, sharpImageColor);
     lowp float hue8 = colorDistance(color8, sharpImageColor);
     
     
     //if(hue0 > gapVal){
     //    sum += sharpImageColor * 0.05;
     //}else{
         sum += colorMix(sharpImageColor,color0, hue0) * 0.05;
     //}
     
     //if(hue1 > gapVal){
     //    sum += sharpImageColor * 0.09;
     //}else{
         sum += colorMix(sharpImageColor,color1, hue1) * 0.09;
     //}
     
     //if(hue2 > gapVal){
     //    sum += sharpImageColor * 0.12;
     //}else{
         sum += colorMix(sharpImageColor,color2, hue2) * 0.12;
     //}
     
     //if(hue3 > gapVal){
     //    sum += sharpImageColor * 0.15;
     //}else{
         sum += colorMix(sharpImageColor,color3, hue3) * 0.15;
     //}

     //if(hue4 > gapVal){
     //    sum += sharpImageColor * 0.18;
     //}else{
         sum += colorMix(sharpImageColor,color4, hue4) * 0.18;
     //}
     
     //if(hue5 > gapVal){
     //    sum += sharpImageColor * 0.15;
     //}else{
         sum += colorMix(sharpImageColor,color5, hue5) * 0.15;
     //}
     
     //if(hue6 > gapVal){
     //    sum += sharpImageColor * 0.12;
     //}else{
         sum += colorMix(sharpImageColor,color6, hue6) * 0.12;
     //}

     //if(hue7 > gapVal){
     //    sum += sharpImageColor * 0.09;
     //}else{
         sum += colorMix(sharpImageColor,color7, hue7) * 0.09;
     //}
     
     //if(hue8 > gapVal){
     //    sum += sharpImageColor * 0.05;
     //}else{
         sum += colorMix(sharpImageColor,color8, hue8) * 0.05;
     //}
     gl_FragColor = sum;
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

@implementation EZColorGaussianFilter

@synthesize blurSize = _blurSize;

- (id) initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
             firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
              secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
            secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString {
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString ? firstStageVertexShaderString : kGPUImageGaussianBlurVertexShaderString0
                              firstStageFragmentShaderFromString:firstStageFragmentShaderString ? firstStageFragmentShaderString : kGPUImageGaussianBlurFragmentShaderString0
                               secondStageVertexShaderFromString:secondStageVertexShaderString ? secondStageVertexShaderString : kGPUImageGaussianBlurVertexShaderString0
                             secondStageFragmentShaderFromString:secondStageFragmentShaderString ? secondStageFragmentShaderString : kGPUImageGaussianBlurFragmentShaderString0])) {
        return nil;
    }
    
    self.blurSize = 1.0;
    
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

- (void)setBlurSize:(CGFloat)newValue;
{
    _blurSize = newValue;
    
    _verticalTexelSpacing = _blurSize;
    _horizontalTexelSpacing = _blurSize;
    
    [self setupFilterForSize:[self sizeOfFBO]];
}


@end
