//
//  EZSkinSharpen.m
//  FeatherCV
//
//  Created by xietian on 14-2-22.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSkinSharpen.h"
NSString *const kImageHomeSharpenFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 leftTextureCoordinate;
 varying highp vec2 rightTextureCoordinate;
 varying highp vec2 topTextureCoordinate;
 varying highp vec2 bottomTextureCoordinate;
 
 varying highp float centerMultiplier;
 varying highp float edgeMultiplier;
 
 uniform sampler2D inputImageTexture;
 
 
 const lowp float skinColor = shaderSkinColor;
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.40){
         fd = fd * fd;
     }else{
         fd = fd * 0.6 + (fd - 0.45) * 2.0;
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     mediump vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     mediump vec3 leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     mediump vec3 rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     mediump vec3 topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     mediump vec3 bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     
     lowp float colorDist = calcHue(textureColor);
     lowp float sharpLevel = 0.4;
     highp float centerMt  = 1.0 + 4.0 * sharpLevel * (1.0 - colorDist);
     highp float edgeMt = sharpLevel * (1.0 - colorDist);
     
     gl_FragColor = vec4((textureColor * centerMt - (leftTextureColor * edgeMt + rightTextureColor * edgeMt + topTextureColor * edgeMt + bottomTextureColor * edgeMt)), texture2D(inputImageTexture, bottomTextureCoordinate).w);
 }
 );

@implementation EZSkinSharpen

- (id) init
{
    self = [super initWithFragmentShaderFromString:kImageHomeSharpenFragmentShaderString];
    return self;
}

@end
