//
//  EZHomeBlendFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeBlendFilter.h"
#import <GPUImageThreeInputFilter.h>
#import "EZFourInputFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kHomeBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 //blurred
 varying highp vec2 textureCoordinate2;
 
 //edge
 varying highp vec2 textureCoordinate3;
 
 //small blur
 varying highp vec2 textureCoordinate4;
 
//varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform sampler2D inputImageTexture4;
 
 uniform lowp float blurRatio;
 uniform lowp float edgeRatio;
 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 smallBlurColor = texture2D(inputImageTexture3, textureCoordinate3);
     lowp vec4 detectedEdge = texture2D(inputImageTexture4, textureCoordinate4);
     /**
      highp vec4 rawYiq = color2YIQ(sharpImageColor);
      // Calculate the hue and chroma
      highp float hue = atan (rawYIQ.b, rawYIQ.g);
      // Make the user's adjustments
      if(hue < lowRed || hue > highBlue){
      gl_FragColor = sharpImageColor;
      return;
      }
      
      if(hue >= lowRed && hue <= midYellow){
      gl_FragColor = adjustColor(rawYiq, lowRed, midYellow, -yellowRedDegree);
      return;
      }
      
      gl_FragColor = adjustColor(rawYiq, midYellow, highBlue, yellowBlueDegree);
      **/
     lowp float finalEdgeRatio = detectedEdge.r;
     gl_FragColor = sharpImageColor * finalEdgeRatio + (1.0 - finalEdgeRatio) * (smallBlurColor * blurRatio + blurredImageColor * (1.0 - blurRatio));// * finalEdgeRatio + (1.0 - finalEdgeRatio) * vec4(0.5);
     
     //smallBlurColor * blurRatio + blurredImageColor * (1.0 - blurRatio)
     //sharpImageColor + (1.0 - detectedEdge.r)* vec4(1.0); //+ (1.0 - detectedEdge.r) * (smallBlurColor * blurRatio + blurredImageColor * (1.0 - blurRatio));
     //sharpImageColor * finalEdgeRatio + (1.0 - finalEdgeRatio) * (smallBlurColor * blurRatio + blurredImageColor * (1.0 - blurRatio)) ;//(smallBlurColor*blurRatio + sharpImageColor*(1.0 - blurRatio)) * detectedEdge.r + blurredImageColor*(1.0 - detectedEdge.r);
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

@implementation EZHomeBlendFilter


- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    hasOverriddenAspectRatio = NO;
    
    // First pass: apply a variable Gaussian blur
    _blurFilter = [[EZHomeBiBlur alloc] init];
    _blurFilter.blurSize = 3.0;
    _blurFilter.distanceNormalizationFactor = 7.5;
    
    _smallBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    _smallBlurFilter.blurSize = 1.0;
    
    //_edgeBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    //blurFilter.blurSize = 2.0;
    //_blurFilter.blurSize = 5.0;
    [self addFilter:_blurFilter];
    [self addFilter:_smallBlurFilter];
    _edgeFilter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    [self addFilter:_edgeFilter];
    //[_edgeFilter addTarget:_edgeBlurFilter];
    // Second pass: combine the blurred image with the original sharp one
    _combineFilter = [[EZFourInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    [self addFilter:_combineFilter];
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    [_smallBlurFilter addTarget:_combineFilter atTextureLocation:2];
    [_edgeFilter addTarget:_combineFilter atTextureLocation:3];
    // To prevent double updating of this filter, disable updates from the sharp image side
    //[_combineFilter disableSecondFrameCheck];
    self.initialFilters = [NSArray arrayWithObjects:_blurFilter, _smallBlurFilter,_edgeFilter,_combineFilter, nil];
    self.terminalFilter = _combineFilter;
    
    return self;
}

- (void) setBlurRatio:(CGFloat)blurRatio
{
    [_combineFilter setFloat:blurRatio forUniformName:@"blurRatio"];
}

- (void) setEdgeRatio:(CGFloat)edgeRatio
{
    [_combineFilter setFloat:edgeRatio forUniformName:@"edgeRatio"];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!hasOverriddenAspectRatio) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        CGFloat aspectRatio = (inputTextureSize.width / inputTextureSize.height);
        [_combineFilter setFloat:aspectRatio forUniformName:@"aspectRatio"];
    }
}
@end
