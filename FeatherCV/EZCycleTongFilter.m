//
//  EZCycleTongFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCycleTongFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageCycleToneCurveFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 //215, 165, 138
 //const lowp vec3 skinColor = vec3(0.783, 0.503, 0.40);
 const lowp vec2 center = vec2(0.5, 0.5);
 uniform lowp float effectRatio;
 
 lowp float calcDistance(lowp vec2 dist)
 {
     highp float fd = distance(dist, center);
     //if(fd < 0.35){
     //    fd = fd * fd;
     //}else{
     //fd = 1.0/(exp((0.35 - fd) * 6.0) + 1.0);
     //}
     fd = fd * fd;
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     //lowp float colorDist = calcHue(textureColor);
     //lowp float dist = calcDistance(textureCoordinate);
     gl_FragColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);//textureColor * dist + (1.0 - dist) * 
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

@implementation EZCycleTongFilter


- (id) init
{
    return [self initWithFragmentShaderFromString:kGPUImageCycleToneCurveFragmentShaderString];
}

- (id) initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithFragmentShaderFromString:fragmentShaderString];
    return self;
}


- (void) setEffectRatio:(CGFloat)effectRatio
{
    //_imageMode = imageMode;
    //[self setInteger:imageMode forUniformName:@"imageMode"];
    _effectRatio = effectRatio;
    [self setFloat:_effectRatio forUniformName:@"effectRatio"];
    
}
@end
