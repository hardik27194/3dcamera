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
 uniform sampler2D guassianBlueTexture;
 uniform sampler2D guassianRedTexture;
 
 const highp float pi = 3.14159265358979;
 uniform highp float lowRed;
 uniform highp float midYellow;
 uniform highp float highBlue;
 
 uniform highp float yellowRedDegree;
 uniform highp float yellowBlueDegree;
 
 uniform lowp float redEnhanceLevel;
 uniform lowp float redRatio;
 
 uniform lowp int guassianMode;
 
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
 
 lowp float guassianTexture(highp float hue, highp float mixDegree)
 {
     if(mixDegree > 0){
         return texture2D(guassianRedTexture, vec2(hue, 0.0)).r;
     }else{
         return texture2D(guassianBlueTexture, vec2(hue, 0.0)).r;
     }
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
     highp float guassianPos = abs((hue - startP)/(endP - startP));
     lowp float gap = gaussianTexture(guassianPos, mid, std);
     if(guassianMode == 1){
         gap = guassian(hue, mid, std);
     }
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
    gaussianRedTextureUniform = [filterProgram uniformIndex:@"guassianRedTexture"];
    gaussianBlueTextureUniform = [filterProgram uniformIndex:@"guassianBlueTexture"];
    
    //hueAdjustUniform = [filterProgram uniformIndex:@"hueAdjust"];
    //self.hue = 0.0;
    return self;
}

- (void) updateAllConfigure
{
      runSynchronouslyOnVideoProcessingQueue(^{
          [self updateBlueGaussianPosition];
          [self updateRedGuassianPosition];
      });
}


- (void)updateBlueGaussianPosition
{
  
        [GPUImageContext useImageProcessingContext];
        if (!guassianBlueTexture)
        {
            glActiveTexture(GL_TEXTURE4);
            glGenTextures(1, &guassianBlueTexture);
            glBindTexture(GL_TEXTURE_2D, guassianBlueTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            guassianBlueByteArray = calloc(256 * 4, sizeof(GLubyte));
        }
        else
        {
            glActiveTexture(GL_TEXTURE4);
            glBindTexture(GL_TEXTURE_2D, guassianBlueTexture);
        }
        [self fillGaussianArray:guassianBlueByteArray start:_highBlue end:_midYellow];
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256 /*width*/, 1 /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, guassianBlueByteArray);
}

-  (void) fillGaussianArray:(GLubyte*)gaussianArray start:(CGFloat)start end:(CGFloat)end
{
    CGFloat gap = (end - start)/256.0;
    CGFloat mid = (start + end)/2.0;
    CGFloat std = (start - end)/5.0;
    CGFloat hue = start;
    for(int i = 0; i < 256; i++){
        gaussianArray[i] = (1.0/(std* sqrt(2.0*M_PI))) * exp(-((hue-mid)*(hue-mid))/(2.0*std*std));
        hue += gap;
    }
}


- (void)updateRedGuassianPosition
{
        [GPUImageContext useImageProcessingContext];
        if (!guassianRedTexture)
        {
            glActiveTexture(GL_TEXTURE3);
            glGenTextures(1, &guassianRedTexture);
            glBindTexture(GL_TEXTURE_2D, guassianRedTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            guassianRedByteArray = calloc(256 * 4, sizeof(GLubyte));
        }
        else
        {
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, guassianRedTexture);
        }
        [self fillGaussianArray:guassianRedByteArray start:_midYellow end:_lowRed];
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256 /*width*/, 1 /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, guassianRedByteArray);
    
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    [self setFilterFBO];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
  	glActiveTexture(GL_TEXTURE2);
  	glBindTexture(GL_TEXTURE_2D, sourceTexture);
  	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, guassianRedTexture);
    glUniform1i(gaussianRedTextureUniform, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, guassianBlueTexture);
    glUniform1i(gaussianBlueTextureUniform, 4);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
