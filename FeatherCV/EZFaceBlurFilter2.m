//
//  EZFaceBlurFilter2.m
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZFaceBlurFilter2.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kFaceBlurShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 
 uniform lowp vec2 vignetteCenter;
 uniform lowp vec3 vignetteColor;
 uniform highp float vignetteStart;
 uniform highp float vignetteEnd;
 
 void main()
 {
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     highp float redhighbar = 255.0/255.0;
     highp float avghigh = 235.0/255.0;
     highp float avglow = 50.0/255.0;
     highp float avglowbegin = 80.0/255.0;
     highp float avghighbegin = 200.0/255.0;
     highp float bluelowbar = 40.0/255.0;
     
     highp float avgcolor = (sharpImageColor.r + sharpImageColor.g + sharpImageColor.b)/3.0;
     highp float graygap = 8.0/255.0;
     
     highp float gapred =abs(sharpImageColor.r - avgcolor);
     highp float gapgreen =abs(sharpImageColor.g - avgcolor);
     highp float gapblue = abs(sharpImageColor.b - avgcolor);
     
     highp float greenbar = (sharpImageColor.g - sharpImageColor.b) * 2.0;
     if(sharpImageColor.b > bluelowbar &&  sharpImageColor.r > sharpImageColor.g && sharpImageColor.r > sharpImageColor.b && sharpImageColor.g > greenbar && avgcolor > avglow && avgcolor < avghighbegin && !(gapred > graygap || gapgreen > graygap|| gapblue > graygap)){
         if(avgcolor > avghighbegin){
             gl_FragColor = sharpImageColor;//mix(blurredImageColor, sharpImageColor, smoothstep(avghighbegin, avghigh, avgcolor));
             return;
         }else if(avgcolor < avglowbegin){
             gl_FragColor = sharpImageColor;//mix(sharpImageColor, blurredImageColor, smoothstep(avglow, avglowbegin, avgcolor));
             return;
         }
         gl_FragColor = sharpImageColor;
         return;
     }
     
     gl_FragColor = sharpImageColor;
 }
 );
#else
NSString *const kFaceBlurShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying vec2 textureCoordinate;
 
 uniform vec2 vignetteCenter;
 uniform vec3 vignetteColor;
 uniform float vignetteStart;
 uniform float vignetteEnd;
 
 void main()
 {
     vec4 sourceImageColor = texture2D(inputImageTexture, textureCoordinate);
     float d = distance(textureCoordinate, vec2(vignetteCenter.x, vignetteCenter.y));
     float percent = smoothstep(vignetteStart, vignetteEnd, d);
     gl_FragColor = vec4(mix(sourceImageColor.rgb, vignetteColor, percent), sourceImageColor.a);
 }
 );
#endif

@implementation EZFaceBlurFilter2

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kFaceBlurShaderString]))
    {
		return nil;
    }
    
    vignetteCenterUniform = [filterProgram uniformIndex:@"vignetteCenter"];
    vignetteColorUniform = [filterProgram uniformIndex:@"vignetteColor"];
    vignetteStartUniform = [filterProgram uniformIndex:@"vignetteStart"];
    vignetteEndUniform = [filterProgram uniformIndex:@"vignetteEnd"];
    
    self.vignetteCenter = (CGPoint){ 0.5f, 0.5f };
    self.vignetteColor = (GPUVector3){ 1.0f, 1.0f, 1.0f };
    self.vignetteStart = 1.0;
    self.vignetteEnd = 0.6;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setVignetteCenter:(CGPoint)newValue
{
    _vignetteCenter = newValue;
    
    [self setPoint:newValue forUniform:vignetteCenterUniform program:filterProgram];
}

- (void)setVignetteColor:(GPUVector3)newValue
{
    _vignetteColor = newValue;
    
    [self setVec3:newValue forUniform:vignetteColorUniform program:filterProgram];
}

- (void)setVignetteStart:(CGFloat)newValue;
{
    _vignetteStart = newValue;
    
    [self setFloat:_vignetteStart forUniform:vignetteStartUniform program:filterProgram];
}

- (void)setVignetteEnd:(CGFloat)newValue;
{
    _vignetteEnd = newValue;
    
    [self setFloat:_vignetteEnd forUniform:vignetteEndUniform program:filterProgram];
}

@end
