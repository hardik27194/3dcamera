//
//  EZHomeBlendFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeBlendFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kHomeBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float realRatio;
 

 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     
     
     gl_FragColor = sharpImageColor*realRatio + blurredImageColor*(1.0 - realRatio) ;
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
    

    _blurFilter = [[EZHomeBiBlur alloc] init];
    //blurFilter.blurSize = 2.0;
    _blurFilter.blurSize = 5.0;
    _blurFilter.distanceNormalizationFactor = 30;
    [self addFilter:_blurFilter];
    // Second pass: combine the blurred image with the original sharp one
    _twoInputFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    [self addFilter:_twoInputFilter];
    self.realRatio = 0.8;
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [_blurFilter addTarget:_twoInputFilter atTextureLocation:1];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    
    
  
    return self;
}


@end
