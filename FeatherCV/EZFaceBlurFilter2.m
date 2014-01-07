//
//  EZ.m
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZFaceBlurFilter2.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kFaceBlurFragmentShaderString2 = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp vec3 skinColor;
 uniform lowp float exponentChange;
 
 uniform lowp float excludeCircleRadius;
 uniform lowp vec2 excludeCirclePoint;
 uniform lowp float excludeBlurSize;
 uniform highp float aspectRatio;
 uniform lowp float realRatio;
 //const lowp vec3 skinColor2 = vec3(0.78, 0.5254, 0.372);
 
 lowp float colorDistance(lowp vec4 src)
{
    highp vec3 delta = src.rgb - skinColor;
    lowp float lowdelta = dot(delta, delta);
    //lowp float skindelta = dot(skinColor, skinColor);
    return min(lowdelta/0.75, 1.0);
}
 
 void main()
 {
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
    
      highp vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
    
     lowp float disRatio = 1.0 - colorDistance(sharpImageColor);
     lowp float finalRatio = disRatio;
     if(disRatio < exponentChange){
        //finalRatio = disRatio * disRatio;
     }
     highp float blurFactor = (1.0 - realRatio) * finalRatio;
     gl_FragColor = blurredImageColor * blurFactor + sharpImageColor * (1.0 - blurFactor);
 }
 );
#else
NSString *const kFaceBlurFragmentShaderString2 = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float excludeCircleRadius;
 uniform vec2 excludeCirclePoint;
 uniform float excludeBlurSize;
 uniform float aspectRatio;
 
 void main()
 {
     vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     
     vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
     float distanceFromCenter = distance(excludeCirclePoint, textureCoordinateToUse);
     
     gl_FragColor = mix(sharpImageColor, blurredImageColor, smoothstep(excludeCircleRadius - excludeBlurSize, excludeCircleRadius, distanceFromCenter));
 }
 );
#endif

@implementation EZFaceBlurFilter2


- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    hasOverriddenAspectRatio = NO;
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[EZColorGaussianFilter alloc] init];
    //blurFilter.blurSize = 2.0;
    self.blurSize = 5.0;
    [self addFilter:blurFilter];
    // Second pass: combine the blurred image with the original sharp one
    selectiveFocusFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kFaceBlurFragmentShaderString2];
    [self addFilter:selectiveFocusFilter];
    self.realRatio = 0.8;
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:selectiveFocusFilter atTextureLocation:1];
    //0.78, 0.5254, 0.372
    self.skinColors = @[@(0.703),@(0.473),@(0.332)];
    self.exponentChange = 0.6;
    // To prevent double updating of this filter, disable updates from the sharp image side
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, selectiveFocusFilter, nil];
    self.terminalFilter = selectiveFocusFilter;
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!hasOverriddenAspectRatio) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        _aspectRatio = (inputTextureSize.width / inputTextureSize.height);
        [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurSize:(CGFloat)newValue;
{
    blurFilter.blurSize = newValue;
}

- (CGFloat)blurSize;
{
    return blurFilter.blurSize;
}

- (void) setRealRatio:(CGFloat)realRatio
{
    _realRatio = realRatio;
    [selectiveFocusFilter setFloat:_realRatio forUniformName:@"realRatio"];
}

- (void) setExponentChange:(CGFloat)exponentChange
{
    _exponentChange = exponentChange;
    [selectiveFocusFilter setFloat:exponentChange forUniformName:@"exponentChange"];
}

- (void) setSkinColors:(NSArray *)skinColors
{
    GPUVector3 skinColor;
    skinColor.one = [[skinColors objectAtIndex:0] floatValue];
    skinColor.two = [[skinColors objectAtIndex:1] floatValue];
    skinColor.three = [[skinColors objectAtIndex:2] floatValue];
    _skinColors = skinColors;
    [selectiveFocusFilter setFloatVec3:skinColor forUniformName:@"skinColor"];
}

- (void)setAspectRatio:(CGFloat)newValue;
{
    hasOverriddenAspectRatio = YES;
    _aspectRatio = newValue;
    [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
}

@end
