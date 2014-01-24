//
//  EZSkinBrighter.m
//  FeatherCV
//
//  Created by xietian on 14-1-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSkinBrighter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageSkinToneCurveFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const lowp vec3 skinColor = vec3(0.753, 0.473, 0.332);
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.8){
         fd = fd * fd * fd;
     }else{
         fd = 1.0/(exp(-fd * fd * 2.0) + 1.0);
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     lowp float colorDist = calcHue(textureColor);

     gl_FragColor = textureColor * colorDist + (1.0 - colorDist) * vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
 }
 );
#else
NSString *const kGPUImageSkinToneCurveFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     
     gl_FragColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
 }
 );
#endif

@implementation EZSkinBrighter


- (id) init
{
    return [self initWithFragmentShaderFromString:kGPUImageSkinToneCurveFragmentShaderString];
}

- (id) initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithFragmentShaderFromString:fragmentShaderString];
    return self;
}

@end
