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
 
 const highp float pi = 3.14159265358979;
 uniform highp float lowRed;
 uniform highp float midYellow;
 uniform highp float highBlue;
 
 uniform highp float yellowRedDegree;
 uniform highp float yellowBlueDegree;
 
 const highp  vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
 const highp  vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
 const highp  vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
 
 const highp  vec4  kYIQToR   = vec4 (1.0, 0.9563, 0.6210, 0.0);
 const highp  vec4  kYIQToG   = vec4 (1.0, -0.2721, -0.6474, 0.0);
 const highp  vec4  kYIQToB   = vec4 (1.0, -1.1070, 1.7046, 0.0);
 
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float   I      = dot (rawcolor, kRGBToI);
     highp float   Q      = dot (rawcolor, kRGBToQ);
     highp float hue = atan(Q, I);
     return hue;
 }

 highp vec4 color2YIQ(lowp vec4 color)
 {
     highp float   YPrime  = dot (color, kRGBToYPrime);
     highp float   I      = dot (color, kRGBToI);
     highp float   Q      = dot (color, kRGBToQ);
     return vec4(YPrime, I, Q, color.w);
 }
 
 
 lowp vec4 YIQ2color(highp vec4 yiqcolor)
 {
     lowp float red = dot(yiqcolor, kYIQToR);
     lowp float green = dot(yiqcolor, kYIQToG);
     lowp float blue = dot(yiqcolor, kYIQToB);
     return vec4(red, green, blue, yiqcolor.w);
 }
 
 
 lowp float gaussian(highp float hue, highp float mid,highp float std)
 {
     return (1.0/(std* sqrt(2.0*pi))) * exp(- ((hue-mid)*(hue-mid))/(2.0*std*std));
 }
 
 
 lowp vec4 adjustColor(highp vec4 rawYiq, highp float startP, highp float endP, highp float mixDegree)
 {
     // highp vec4 rawYiq = color2YIQ(rawcolor);
     // Calculate the hue and chroma
     highp float hue = atan (rawYiq.b, rawYiq.g);
     // Make the user's adjustments
     //if(hue < startP || hue > endP){
     //    return rawcolor;
     //}
     //hue += (-hueAdjust);
     highp float mid = (startP + endP)/2.0;
     //The higher the std, the narrower the distribution
     highp float std = abs(startP - endP)/5.0;
     lowp float gap = gaussian(hue, mid, std);
     hue += gap * mixDegree;
     highp float chroma  = sqrt(rawYiq.g * rawYiq.g + rawYiq.b * rawYiq.b);
     // Convert back to YIQ
     highp float Q = chroma * sin (hue);
     highp float I = chroma * cos (hue);
     // Convert back to RGB
     return YIQ2color(vec4(rawYiq.r, I, Q, rawYiq.w));
 }
 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     
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
     gl_FragColor = sharpImageColor;
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
    
    self.midYellow = -112;
    self.highBlue = 10;
    self.lowRed = -150;
    self.yellowRedDegree = -10;
    self.yellowBlueDegree = 10;
    
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

/**
 uniform highp float lowRed;
 uniform highp float midYellow;
 uniform highp float highBlue;
 
 uniform highp float yellowRedDegree;
 uniform highp float yellowBlueDegree;
 **/
- (void) setLowRed:(CGFloat)lowRed
{
    _lowRed = fmodf(lowRed, 360.0) * M_PI/180.0;
    [selectiveFocusFilter setFloat:_lowRed forUniformName:@"lowRed"];
}

- (void) setMidYellow:(CGFloat)midYellow
{
    _midYellow = fmodf(midYellow, 360.0) * M_PI/180.0;
    [selectiveFocusFilter setFloat:_midYellow forUniformName:@"midYellow"];
}

- (void) setHighBlue:(CGFloat)highBlue
{
    _highBlue = fmodf(highBlue, 360.0) * M_PI/180.0;
    [selectiveFocusFilter setFloat:_highBlue forUniformName:@"highBlue"];
}

- (void) setYellowBlueDegree:(CGFloat)yellowBlueDegree
{
    _yellowBlueDegree = fmodf(yellowBlueDegree, 360.0) * M_PI/180.0;
    [selectiveFocusFilter setFloat:_yellowBlueDegree forUniformName:@"yellowBlueDegree"];
}

- (void) setYellowRedDegree:(CGFloat)yellowRedDegree
{
    _yellowRedDegree = fmodf(yellowRedDegree, 360.0) * M_PI/180.0;
    [selectiveFocusFilter setFloat:_yellowRedDegree forUniformName:@"yellowRedDegree"];
}

@end
