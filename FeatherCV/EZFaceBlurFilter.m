//
//  EZ.m
//  FeatherCV
//
//  Created by xietian on 13-12-20.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZFaceBlurFilter.h"
#import "EZColorGaussianFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kFaceBlurFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float excludeCircleRadius;
 uniform lowp vec2 excludeCirclePoint;
 uniform lowp float excludeBlurSize;
 uniform highp float aspectRatio;
 uniform lowp float realRatio;
 
 
 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 distanceVec = sharpImageColor - blurredImageColor;
     highp float distance = dot(distanceVec, distanceVec);
     
     if(distance > 1.0){
         gl_FragColor = vec4((sharpImageColor + distanceVec*1.4).xyz, sharpImageColor.w);
     }else{
         gl_FragColor = blurredImageColor*(1.0 - realRatio) + sharpImageColor*realRatio;
     }
     
     /**
     highp vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
     
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
     if(sharpImageColor.b > bluelowbar &&  sharpImageColor.r > sharpImageColor.g && sharpImageColor.r > sharpImageColor.b && sharpImageColor.g > greenbar && avgcolor > avglow && avgcolor < avghighbegin && !(gapred < graygap && gapgreen < graygap && gapblue < graygap)){
         
         return;
     }
      **/
 
     // gl_FragColor = blurredImageColor*(1.0 - realRatio) + sharpImageColor*realRatio;
     //gl_FragColor = sharpImageColor;
 }
 );
#else
NSString *const kFaceBlurFragmentShaderString = SHADER_STRING
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

@implementation EZFaceBlurFilter

@synthesize excludeCirclePoint = _excludeCirclePoint, excludeCircleRadius = _excludeCircleRadius, excludeBlurSize = _excludeBlurSize;
@synthesize blurSize = _blurSize;
@synthesize aspectRatio = _aspectRatio;

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
    selectiveFocusFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kFaceBlurFragmentShaderString];
    [self addFilter:selectiveFocusFilter];
    self.realRatio = 0.8;
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:selectiveFocusFilter atTextureLocation:1];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, selectiveFocusFilter, nil];
    self.terminalFilter = selectiveFocusFilter;
    
    
    
    self.excludeCircleRadius = 60.0/320.0;
    self.excludeCirclePoint = CGPointMake(0.5f, 0.5f);
    self.excludeBlurSize = 30.0/320.0;
    
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

- (void)setExcludeCirclePoint:(CGPoint)newValue;
{
    _excludeCirclePoint = newValue;
    [selectiveFocusFilter setPoint:newValue forUniformName:@"excludeCirclePoint"];
}

- (void)setExcludeCircleRadius:(CGFloat)newValue;
{
    _excludeCircleRadius = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeCircleRadius"];
}

- (void) setRealRatio:(CGFloat)realRatio
{
    _realRatio = realRatio;
    [selectiveFocusFilter setFloat:_realRatio forUniformName:@"realRatio"];
}

- (void)setExcludeBlurSize:(CGFloat)newValue;
{
    _excludeBlurSize = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeBlurSize"];
}

- (void)setAspectRatio:(CGFloat)newValue;
{
    hasOverriddenAspectRatio = YES;
    _aspectRatio = newValue;
    [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
}

@end
