//
//  EZSkinMaskFilter.m
//  FeatherCV
//
//  Created by xietian on 14-2-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSkinMaskFilter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageSkinMaskFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform vec4 faceRegion;
 uniform lowp float faceThreshold;
 //215, 165, 138
 const lowp vec3 skinColor = vec3(0.783, 0.503, 0.40);
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.725){
         fd = fd * fd * fd;
     }else{
         fd = 1.0/(exp(-fd * 1.5) + 1.0);
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     if(textureCoordinate.x > faceRegion.x && textureCoordinate.x < faceRegion.y && textureCoordinate.y > faceRegion.z && textureCoordinate.y < faceRegion.w){
         lowp float dist = distance(skinColor, textureColor.rgb);
         
     }
     /**
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     lowp float colorDist = calcHue(textureColor);
     
     gl_FragColor = textureColor * colorDist + (1.0 - colorDist) * vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
      **/
     
 }
 );
#else
NSString *const kGPUImageSkinMaskFragmentShaderString = SHADER_STRING
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

@implementation EZSkinMaskFilter


- (id) init
{
    return [self initWithFragmentShaderFromString:kGPUImageSkinMaskFragmentShaderString];
}

- (id) initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithFragmentShaderFromString:fragmentShaderString];
    self.faceThreshold = 0.6;
    return self;
}


- (void) setFaceThreshold:(CGFloat)faceThreshold
{
    _faceThreshold = faceThreshold;
    [self setInteger:_faceThreshold forUniformName:@"faceThreshold"];
}

- (void) setFaceRegion:(NSArray *)faceRegion
{
    GPUVector4 faceVector;
    faceVector.one = [[faceRegion objectAtIndex:0] floatValue];
    faceVector.two = [[faceRegion objectAtIndex:1] floatValue];
    faceVector.three = [[faceRegion objectAtIndex:2] floatValue];
    faceVector.four = [[faceRegion objectAtIndex:3] floatValue];
    [self setFloatVec4:faceVector forUniform:@"faceRegion"];
}

@end
