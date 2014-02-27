//
//  EZSharpenGaussian.m
//  FeatherCV
//
//  Created by xietian on 14-2-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSharpenGaussian.h"

NSString *const EZGaussianSharpenVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 const int GAUSSIAN_SAMPLES = 13;
 
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



NSString *const EZGaussianSharpenFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 13;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 const lowp vec3 skinColor = shaderSkinColor;
 
 lowp float calcHue(mediump vec3 rawcolor)
 {
     highp float fd = distance(rawcolor, skinColor);
     if(fd < shaderSkinRange){
         fd = fd;
     }else{
         fd = shaderSkinRange + (fd - shaderSkinRange) * 10.0;
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     lowp vec4 orgColor = texture2D(inputImageTexture, textureCoordinate);
     
     highp vec4 sum = vec4(0.0);
     
     sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.05;
     sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.15;
     lowp vec4 centralColor = texture2D(inputImageTexture, blurCoordinates[6]);
     //sum +=                                     centralColor * 0.18;
     
     sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.18;
     sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[9]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[10]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[11]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[12]) * 0.05;
     
     sum = sum/1.54;
     
     //sum += texture2D(inputImageTexture, blurCoordinates[10]) * 0.05
     //mediump vec3 sharpGap = textureColor * 4.0 - (leftTextureColor  + rightTextureColor + topTextureColor + bottomTextureColor);
     highp float sharpDist = distance(centralColor.rgb, sum.rgb);
     lowp float sharpenBar = 0.1;
     if(sharpDist < sharpenBar){
         sharpDist = sharpDist * sharpDist;
     }else{
         sharpDist = sharpenBar + (sharpDist - sharpenBar) * 1.2;
              }
     mediump float sharpenRatio = 1.0;
     lowp float colorDist = calcHue(centralColor.rgb);
     //sharpDist = sharpDist * sharpenRatio;
     if(sharpDist > 0.25){
         sharpDist = 0.25 + (sharpDist - 0.25) * 0.1;
     }
     sharpDist = min(0.3, sharpDist);
     gl_FragColor = vec4(vec3(centralColor.rgb + (centralColor.rgb - sum.rgb) * sharpDist), centralColor.w);
     //gl_FragColor = orgColor;
     //gl_FragColor = vec4(vec3(sharpDist), centralColor.w);
 }
 );


NSString *const EZSharpenFinalString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 
 void main()
 {
     lowp vec4 sum = vec4(0.0);
     
     sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.05;
     sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.15;
     lowp vec4 centralColor = texture2D(inputImageTexture, blurCoordinates[4]);
     sum +=                                     centralColor * 0.18;
     sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.15;
     sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.12;
     sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.09;
     sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.05;

     gl_FragColor = centralColor;
 }
 );


@implementation EZSharpenGaussian

- (id) init
{
    self = [super initWithFirstStageVertexShaderFromString:EZGaussianSharpenVertexShaderString firstStageFragmentShaderFromString:EZGaussianSharpenFragmentShaderString secondStageVertexShaderFromString:EZGaussianSharpenVertexShaderString secondStageFragmentShaderFromString:EZGaussianSharpenFragmentShaderString];
    return self;
}

@end
