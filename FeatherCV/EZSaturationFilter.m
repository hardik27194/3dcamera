//
//  EZSaturationFilter.m
//  FeatherCV
//
//  Created by xietian on 13-12-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZSaturationFilter.h"
// Adapted from http://stackoverflow.com/questions/9234724/how-to-change-hue-of-a-texture-with-glsl - see for code and discussion
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageMySatuFragmentShaderString = SHADER_STRING
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
     
     
     
     highp vec4 rawYiq = color2YIQ(sharpImageColor);
     // Calculate the hue and chroma
     highp float hue = atan (rawYiq.b, rawYiq.g);

      if(hue > lowRed || hue < highBlue){
          //gl_FragColor = sharpImageColor;
          //return;
      }
      
      else if(hue <= lowRed && hue >= midYellow){
          sharpImageColor = adjustColor(rawYiq, midYellow, lowRed, yellowRedDegree);
          //return;
      }
      else
      {
          sharpImageColor = adjustColor(rawYiq, highBlue, midYellow, -yellowBlueDegree);
      }
     
    gl_FragColor = sharpImageColor;
     /**
     if(hue > -0.7 && hue < -0.6){
         gl_FragColor = sharpImageColor*0.1;
         return;
     }
      **/
     
     //gl_FragColor = sharpImageColor*0.1;
     //gl_FragColor = sharpImageColor;
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

@implementation EZSaturationFilter


- (id)init
{
    if(! (self = [super initWithFragmentShaderFromString:kGPUImageMySatuFragmentShaderString]) )
    {
        return nil;
    }
    self.lowRed = 20;
    self.midYellow = -30;
    self.highBlue = -80;
    self.yellowRedDegree = 10;
    self.yellowBlueDegree = 10;
    
    //hueAdjustUniform = [filterProgram uniformIndex:@"hueAdjust"];
    //self.hue = 0.0;
    
    return self;
}

- (void) setLowRed:(CGFloat)lowRed
{
    _lowRed = fmodf(lowRed, 360.0) * M_PI/180.0;
    [self setFloat:_lowRed forUniformName:@"lowRed"];
}

- (void) setMidYellow:(CGFloat)midYellow
{
    _midYellow = fmodf(midYellow, 360.0) * M_PI/180.0;
    [self setFloat:_midYellow forUniformName:@"midYellow"];
}

- (void) setHighBlue:(CGFloat)highBlue
{
    _highBlue = fmodf(highBlue, 360.0) * M_PI/180.0;
    [self setFloat:_highBlue forUniformName:@"highBlue"];
}

- (void) setYellowBlueDegree:(CGFloat)yellowBlueDegree
{
    _yellowBlueDegree = fmodf(yellowBlueDegree, 360.0) * M_PI/180.0;
    [self setFloat:_yellowBlueDegree forUniformName:@"yellowBlueDegree"];
}

- (void) setYellowRedDegree:(CGFloat)yellowRedDegree
{
    _yellowRedDegree = fmodf(yellowRedDegree, 360.0) * M_PI/180.0;
    [self setFloat:_yellowRedDegree forUniformName:@"yellowRedDegree"];
}
@end
