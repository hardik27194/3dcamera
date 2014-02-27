//
//  EZChromaBiFilter.m
//  FeatherCV
//
//  Created by xietian on 14-2-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZChromaBiFilter.h"

NSString *const EZChromaBilateralFilterFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 uniform mediump float distanceNormalizationFactor;
 uniform lowp int imageMode;
 const mediump mat3 XYZtoRGB = mat3(3.2406, -1.5372, -0.4986, -0.9689, 1.8758, 0.0415, 0.0557, -0.2040, 1.0570);
 
 const mediump mat3 RGBtoXYZ = mat3(0.4124, 0.3576, 0.1805,0.2126, 0.7152, 0.0722,0.0193, 0.1192, 0.9505);
 
 highp float normalizeColor(highp float cl)
 {
     if ( cl > 0.0031308 )
         return 1.055 * pow(( 1.0 / 2.4 ), cl) - 0.055;
     else
         return 12.92 * cl;
 }
 
 highp float normalizeXYZ(highp float cl)
 {
     if ( cl > 0.04045 )
         return pow(2.4, (cl + 0.055 ) / 1.055 );
     else
         return cl / 12.92;
 }
 
 lowp vec3 xyz2rgb (highp vec3 xyzColor)
 {
     //var_X = X / 100        //X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
     //var_Y = Y / 100        //Y from 0 to 100.000
     //var_Z = Z / 100        //Z from 0 to 108.883
     xyzColor = xyzColor/100.0;
     highp rgbColor = XYZtoRGB * xyzColor;
     rgbColor.r = normalizeColor(rgbColor.r);
     rgbColor.g = normalizeColor(rgbColor.g);
     rgbColor.b = normalizeColor(rgbColor.b);
     return rgbColor;
 }
 
 highp vec3 rgb2xyz (lowp vec3 rgbColor)
 {
    highp vec3 midColor;
    midColor.r = normalizeXYZ(rgbColor.r);
    midColor.g = normalizeXYZ(rgbColor.g);
    midColor.b = normalizeXYZ(rgbColor.b);
    
    midColor = midColor * 100.0;
    //Observer. = 2°, Illuminant = D65
     return RGBtoXYZ * midColor;
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


@implementation EZChromaBiFilter

- (id) init
{
    self = [super initWithFragmentShaderFromString:EZChromaBilateralFilterFragmentShaderString];
    return self;
}

- (void) setImageMode:(int)imageMode
{
    _imageMode = imageMode;
    [self setInteger:_imageMode forUniformName:@"imageMode"];
}

@end
