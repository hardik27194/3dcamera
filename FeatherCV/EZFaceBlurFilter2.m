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
 
 uniform lowp float excludeCircleRadius;
 uniform lowp vec2 excludeCirclePoint;
 uniform lowp float excludeBlurSize;
 uniform highp float aspectRatio;
 uniform lowp float realRatio;
 const lowp vec3 skinColor = vec3(0.78, 0.5254, 0.372);
 
 lowp float colorDistance(lowp vec4 src)
{
    highp vec3 delta = src.rgb - skinColor;
    lowp float lowdelta = dot(delta, delta);
    lowp float skindelta = dot(skinColor, skinColor);
    return lowdelta/skindelta;
}
 
 void main()
 {
     const lowp vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
     const lowp vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
     const lowp vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
     
     const lowp vec4  kYIQToR   = vec4 (1.0, 0.9563, 0.6210, 0.0);
     const lowp vec4  kYIQToG   = vec4 (1.0, -0.2721, -0.6474, 0.0);
     const lowp vec4  kYIQToB   = vec4 (1.0, -1.1070, 1.7046, 0.0);
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
    
      highp vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
      
      highp float redhighbar = 255.0/255.0;
      highp float avghigh = 235.0/255.0;
      highp float avglow = 50.0/255.0;
      highp float avglowbegin = 80.0/255.0;
      highp float avghighbegin = 200.0/255.0;
      highp float bluelowbar = 40.0/255.0;
      
      //highp float avgcolor = (sharpImageColor.r + sharpImageColor.g + sharpImageColor.b)/3.0;
      //highp float graygap = 8.0/255.0;
      
      //highp float gapred =abs(sharpImageColor.r - avgcolor);
      //highp float gapgreen =abs(sharpImageColor.g - avgcolor);
      //highp float gapblue = abs(sharpImageColor.b - avgcolor);
      //highp float greenbar = (sharpImageColor.g - sharpImageColor.b) * 2.0;
     
     /**
      if(sharpImageColor.b > bluelowbar &&  sharpImageColor.r > sharpImageColor.g && sharpImageColor.r > sharpImageColor.b && sharpImageColor.g > greenbar && avgcolor > avglow && avgcolor < avghighbegin && !(gapred < graygap && gapgreen < graygap && gapblue < graygap))
      **/
     //highp float   YPrime  = dot (sharpImageColor, kRGBToYPrime);
     //highp float   I      = dot (sharpImageColor, kRGBToI);
     //highp float   Q      = dot (sharpImageColor, kRGBToQ);
     
     // Calculate the hue and chroma
     //highp float   hue     = atan (Q, I);
     
     //highp float   orangeHue = (-138.0/180.0) * 3.1415926535;
     
     highp float comp1 = 2.0 * sharpImageColor.b - sharpImageColor.g;
     highp float comp2 = sharpImageColor.b - bluelowbar;
     highp float comp3 = sharpImageColor.r - sharpImageColor.b;
     //highp float comp4 = sharpImageColor.r - sharpImageColor.b;
     lowp vec4 distanceVec = sharpImageColor - blurredImageColor;
     highp float distance = dot(distanceVec, distanceVec);
     if(distance > 0.8){
         gl_FragColor = vec4((sharpImageColor + distanceVec*1.2).xyz, sharpImageColor.w);
     }else{
         //highp float delta = 1.0 - (abs(hue - orangeHue)/(2.0 * 3.1415926535));
         lowp float disRatio = 1.0 - colorDistance(sharpImageColor);
         lowp float finalRatio = disRatio * disRatio * disRatio;
         highp float blurFactor = (1.0 - realRatio) * finalRatio;
         gl_FragColor = blurredImageColor * blurFactor + sharpImageColor * (1.0 - blurFactor);
     }
     /**
      if(comp3 > 0.0){
          lowp vec4 distanceVec = sharpImageColor - blurredImageColor;
          highp float distance = dot(distanceVec, distanceVec);
          if(distance > 0.8){
              gl_FragColor = vec4((sharpImageColor + distanceVec*1.2).xyz, sharpImageColor.w);
          }else{
              gl_FragColor = blurredImageColor*(1.0 - realRatio) + sharpImageColor*realRatio;
          }
          //gl_FragColor = blurredImageColor*(1.0 - realRatio) + sharpImageColor*realRatio;
          return;
      }else{
          //highp vec3 colorDist = vec3(min(0.0, comp1), min(0.0, comp2), min(0.0, comp3));
          //highp float colorMag = max(dot(colorDist, colorDist), 1.0)/1.0;
          highp float colorMag = sqrt(sqrt(comp3 * comp3)/1.0;
          highp float blurFactor = (1.0 - realRatio)*(1.0 - colorMag);
          gl_FragColor = blurredImageColor * blurFactor + sharpImageColor*(1.0 - blurFactor);
          //gl_FragColor = sharpImageColor * 0.2;
          //gl_FragColor = blurredImageColor*(1.0 - realRatio) + sharpImageColor*realRatio;
          return;
      }
     **/
     //gl_FragColor = sharpImageColor;
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
    selectiveFocusFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kFaceBlurFragmentShaderString2];
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
