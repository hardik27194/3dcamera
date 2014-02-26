//
//  EZSharpenGaussian.m
//  FeatherCV
//
//  Created by xietian on 14-2-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSharpenGaussian.h"
NSString *const EZGaussianSharpenFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 const lowp int GAUSSIAN_SAMPLES = 9;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];
 
 const lowp vec3 skinColor = shaderSkinColor;
 
 lowp float calcHue(mediump vec3 rawcolor)
 {
     highp float fd = distance(rawcolor, skinColor);
     if(fd < shaderSkinRange){
         fd = fd;
     }else{
         fd = fd + (fd - shaderSkinRange) * 2.0;
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
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
     //mediump vec3 sharpGap = textureColor * 4.0 - (leftTextureColor  + rightTextureColor + topTextureColor + bottomTextureColor);
     highp float sharpDist = distance(centralColor.rgb, sum.rgb);
     lowp float sharpenBar = 0.1;
     if(sharpDist < sharpenBar){
         sharpDist = sharpDist * sharpDist;
     }else{
         sharpDist = sharpenBar + (sharpDist - sharpenBar) * 1.2;
         if(sharpDist > 0.7){
             sharpDist = 0.7 + (sharpDist - 0.7) * 0.1;
         }
     }
     lowp float sharpenRatio = 2.0;
     lowp float colorDist = calcHue(centralColor.rgb);
     sharpDist = sharpDist * colorDist * sharpenRatio;
     sharpDist = min(1.0, sharpDist);
     gl_FragColor = vec4(vec3(centralColor.rgb + (centralColor.rgb - sum.rgb) * sharpDist), centralColor.w);
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
    self = [super initWithFirstStageVertexShaderFromString:nil firstStageFragmentShaderFromString:EZGaussianSharpenFragmentShaderString secondStageVertexShaderFromString:nil secondStageFragmentShaderFromString:EZGaussianSharpenFragmentShaderString];
    return self;
}

@end
