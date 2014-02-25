//
//  EZColorBrighter.m
//  FeatherCV
//
//  Created by xietian on 14-1-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZColorBrighter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageMyColorFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 const highp float pi = 3.14159265358979;
 uniform highp float lowRed;
 uniform highp float midYellow;
 uniform highp float highBlue;
 
 uniform highp float yellowRedDegree;
 uniform highp float yellowBlueDegree;
 
 uniform lowp float redEnhanceLevel;
 uniform lowp float redRatio;
 
 uniform lowp float blueEnhanceLevel;
 uniform lowp float blueRatio;
 uniform lowp float blueLimit;
 
 uniform lowp float greenEnhanceLevel;
 uniform lowp float greenRatio;
 uniform lowp float greenLimit;
 
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
     return (1.0/(std* sqrt(2.0*pi))) * exp(-((hue-mid)*(hue-mid))/(2.0*std*std));
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
     lowp vec4 fixRedColor =  sharpImageColor;
     lowp float red2Green = sharpImageColor.r - sharpImageColor.g;
     lowp float red2Blue = sharpImageColor.r - sharpImageColor.b;
     
     lowp float blue2Red = sharpImageColor.b - sharpImageColor.r;
     lowp float blue2Green = sharpImageColor.b - sharpImageColor.g;
     lowp float levelDiff = min(red2Green + red2Blue - redEnhanceLevel, 1.0);
     
     
     //lowp float green2Red = sharpImageColor.g - sharpImageColor.r;
     //lowp float green2Blue = sharpImageColor.g - sharpImageColor.b;
     lowp float greenLevelDiff = min(-red2Green - blue2Green - greenEnhanceLevel, 1.0);
     
     if(red2Blue > 0.0 && red2Green > 0.0 && levelDiff > 0.0){
         lowp float deltaRed = red2Green * red2Green * redRatio * levelDiff;
         fixRedColor.r = min(1.0, sharpImageColor.r + deltaRed);
         lowp float halfRed = deltaRed / 2.0;
         fixRedColor.g = max(0.0, sharpImageColor.g - halfRed);
         fixRedColor.b = max(0.0, sharpImageColor.b - halfRed);
     }else if(blue2Red > 0.0 && blue2Green > 0.0 && (blue2Green + blue2Red) > blueEnhanceLevel){
         /**
         lowp float redBlueRatio = (sharpImageColor.r/sharpImageColor.b) * blueRatio;
         lowp float plusRed = sharpImageColor.b * redBlueRatio;
         fixRedColor.r = min(1.0, sharpImageColor.r + plusRed);
         fixRedColor.b = max(0.0, sharpImageColor.b - plusRed);
          **/
     }else if(red2Green < 0.0 && blue2Green < 0.0 && greenLevelDiff > 0.0){
         lowp float deltaGreen = red2Green * red2Green * greenRatio * greenLevelDiff;
         lowp float halfDelta = deltaGreen/2.0;
         fixRedColor.g = min(1.0, sharpImageColor.g + deltaGreen);
         fixRedColor.r = max(0.0, sharpImageColor.r - halfDelta);
         fixRedColor.b = max(0.0, sharpImageColor.b - halfDelta);
     }
     gl_FragColor = fixRedColor;
 }
 );
#else
NSString *const kGPUImageHueFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float hueAdjust;
 const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
 const vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
 const vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
 
 const vec4  kYIQToR   = vec4 (1.0, 0.9563, 0.6210, 0.0);
 const vec4  kYIQToG   = vec4 (1.0, -0.2721, -0.6474, 0.0);
 const vec4  kYIQToB   = vec4 (1.0, -1.1070, 1.7046, 0.0);
 
 void main ()
 {
     // Sample the input pixel
     vec4 color   = texture2D(inputImageTexture, textureCoordinate);
     
     // Convert to YIQ
     float   YPrime  = dot (color, kRGBToYPrime);
     float   I      = dot (color, kRGBToI);
     float   Q      = dot (color, kRGBToQ);
     
     // Calculate the hue and chroma
     float   hue     = atan (Q, I);
     float   chroma  = sqrt (I * I + Q * Q);
     
     // Make the user's adjustments
     hue += (-hueAdjust); //why negative rotation?
     
     // Convert back to YIQ
     Q = chroma * sin (hue);
     I = chroma * cos (hue);
     
     // Convert back to RGB
     vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
     color.r = dot (yIQ, kYIQToR);
     color.g = dot (yIQ, kYIQToG);
     color.b = dot (yIQ, kYIQToB);
     
     // Save the result
     gl_FragColor = color;
 }
 );
#endif

@implementation EZColorBrighter


- (id)init
{
    if(! (self = [super initWithFragmentShaderFromString:kGPUImageMyColorFragmentShaderString]) )
    {
        return nil;
    }
    self.redRatio = 0.15;
    self.redEnhanceLevel = 0.40;
    return self;
}

- (void) setBlueRatio:(CGFloat)blueRatio
{
    _blueRatio = blueRatio;
    [self setFloat:_blueRatio forUniformName:@"blueRatio"];
    
}

- (void) setBlueEnhanceLevel:(CGFloat)blueEnhanceLevel
{
    _blueEnhanceLevel = blueEnhanceLevel;
    [self setFloat:_blueEnhanceLevel forUniformName:@"blueEnhanceLevel"];
}


- (void) setRedRatio:(CGFloat)redRatio
{
    _redRatio = redRatio;
    [self setFloat:_redRatio forUniformName:@"redRatio"];
    
}

- (void) setRedEnhanceLevel:(CGFloat)redEnhanceLevel
{
    _redEnhanceLevel = redEnhanceLevel;
    [self setFloat:_redEnhanceLevel forUniformName:@"redEnhanceLevel"];
}

- (void) setGreenRatio:(CGFloat)greenRatio
{
    _greenRatio = greenRatio;
    [self setFloat:_greenRatio forUniformName:@"greenRatio"];
    
}

- (void) setGreenEnhanceLevel:(CGFloat)greenEnhanceLevel
{
    _greenEnhanceLevel = greenEnhanceLevel;
    [self setFloat:_greenEnhanceLevel forUniformName:@"greenEnhanceLevel"];
}


@end
