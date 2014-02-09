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
 uniform lowp vec3 skinColor;
 uniform lowp vec4 faceRegion;
 
 uniform lowp float blurRatio;
 uniform lowp float edgeRatio;
 uniform lowp int imageMode;
 uniform lowp int showFace;
 
 const lowp vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
 const lowp vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
 const lowp vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 lowp float calcHueOld(lowp vec4 rawcolor)
 {

     highp float   I      = dot (rawcolor, kRGBToI);
     highp float   Q      = dot (rawcolor, kRGBToQ);
     highp float hue = atan(Q, I);
     
     highp float  OI = dot(skinColor, kRGBToI.rgb);
     highp float  OQ = dot(skinColor, kRGBToQ.rgb);
     highp float orghue = atan(OQ, OI);
     
     lowp float res = 1.0/(exp(3.1415926535 - abs(hue - orghue)) + 1.0);
     return res;
 }
 
 lowp float calcHue(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.7){
         fd = fd * fd * fd;
     }else{
         fd = 1.0/(exp(-fd * 2.5) + 1.0);
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 lowp float calcLineDist(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.5){
         fd = fd*0.6;
     }else{
         fd = fd * 5.0;//1.0/(exp(-fd * 8.0) + 1.0);
     }
     return fd;
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 smallBlurColor = texture2D(inputImageTexture3, textureCoordinate3);
     lowp vec4 detectedEdge = texture2D(inputImageTexture4, textureCoordinate4);
     lowp float finalEdgeRatio = detectedEdge.r;
     /**
     if(showFace == 1 && textureCoordinate.x > faceRegion.x && textureCoordinate.x < faceRegion.y && textureCoordinate.y > faceRegion.z && textureCoordinate.y < faceRegion.w){
         gl_FragColor = sharpImageColor * 0.3;
     }else{
         gl_FragColor = sharpImageColor;
     }
      **/
     if(imageMode == 0){
         lowp float colorDist = calcHue(sharpImageColor);
         lowp float lineDist = calcLineDist(sharpImageColor);
         lowp vec3 darkColor = vec3(0.35);
         lowp float brightness = dot(sharpImageColor.rgb, W);
         brightness = brightness * brightness;
         finalEdgeRatio = finalEdgeRatio * (1.0 - brightness);
         //colorDist * sharpImageColor +  (1.0 - colorDist) *
         
         if(finalEdgeRatio > 0.08){
             finalEdgeRatio = 1.0;
         }
         
         //else if(finalEdgeRatio < 0.2){
         //    finalEdgeRatio = 0.0;
         //}
         finalEdgeRatio = min(finalEdgeRatio * lineDist, 1.0);
         gl_FragColor = colorDist * sharpImageColor +  (1.0 - colorDist) * (sharpImageColor * finalEdgeRatio + (1.0 - finalEdgeRatio) * (sharpImageColor*blurRatio + (1.0 - blurRatio)*blurredImageColor));// finalEdgeRatio + (1.0 - finalEdgeRatio) * vec4(0.5);
     }else if(imageMode == 1){
         gl_FragColor = detectedEdge;
     }else if(imageMode == 2){
         gl_FragColor = sharpImageColor;
     }
     //gl_FragColor = blurredImageColor;
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
    
    _smallBlurFilter = [[EZHomeLineBiFilter alloc] init];
    _smallBlurFilter.blurSize = 1.0;
    
    _skinBrighter = [[EZSkinBrighter alloc] init];
    [_skinBrighter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.125), pointValue(0.25, 0.285), pointValue(0.5, 0.535), pointValue(0.75, 0.785), pointValue(1.0, 1.0)]];
    [_skinBrighter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.128), pointValue(0.25, 0.254), pointValue(0.5, 0.504), pointValue(0.75, 0.754), pointValue(1.0, 1.0)]];
    [_skinBrighter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.123), pointValue(0.25, 0.247), pointValue(0.5, 0.497), pointValue(0.75, 0.747), pointValue(1.0, 1.0)]];
    //[_skinBrighter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.130), pointValue(0.25, 0.255), pointValue(0.5, 0.505), pointValue(0.75, 0.755), pointValue(1.0, 1.0)]];
    //[_skinBrighter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.120), pointValue(0.25, 0.245), pointValue(0.5, 0.495), pointValue(0.75, 0.745), pointValue(1.0, 1.0)]];
    //_edgeBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    //blurFilter.blurSize = 2.0;
    //_blurFilter.blurSize = 5.0;
    //[self addFilter:_blurFilter];
    //[self addFilter:_smallBlurFilter];
    _edgeFilter = [[EZHomeEdgeFilter alloc] init];
    [self addFilter:_edgeFilter];
    //[_edgeFilter addTarget:_edgeBlurFilter];
    // Second pass: combine the blurred image with the original sharp one
    _combineFilter = [[EZFourInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    //[self addFilter:_combineFilter];
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [self addFilter:_skinBrighter];
    
    [_skinBrighter addTarget:_blurFilter];
    [_skinBrighter addTarget:_smallBlurFilter];
    [_edgeFilter addTarget:_smallBlurFilter atTextureLocation:1];
    [_skinBrighter addTarget:_combineFilter atTextureLocation:0];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    [_smallBlurFilter addTarget:_combineFilter atTextureLocation:2];
    [_edgeFilter addTarget:_combineFilter atTextureLocation:3];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    //[_combineFilter disableSecondFrameCheck];
    self.initialFilters = [NSArray arrayWithObjects:_edgeFilter,_skinBrighter, _combineFilter, nil];
    self.skinColors = @[@(0.753),@(0.473),@(0.332)];
    self.terminalFilter = _combineFilter;
    //self.edgeRatio =
    self.imageMode = 0;
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

- (void) setImageMode:(int)imageMode
{
    _imageMode = imageMode;
    [_combineFilter setInteger:imageMode forUniformName:@"imageMode"];
}

- (void) setSkinColors:(NSArray *)skinColors
{
    GPUVector3 skinColor;
    skinColor.one = [[skinColors objectAtIndex:0] floatValue];
    skinColor.two = [[skinColors objectAtIndex:1] floatValue];
    skinColor.three = [[skinColors objectAtIndex:2] floatValue];
    _skinColors = skinColors;
    [_combineFilter setFloatVec3:skinColor forUniformName:@"skinColor"];
}

- (void) setShowFace:(int)showFace
{
    _showFace = showFace;
    [_combineFilter setInteger:_showFace forUniformName:@"showFace"];
}

- (void) setFaceRegion:(NSArray *)faceRegion
{

    GPUVector4 faceVector;
    faceVector.one = [[faceRegion objectAtIndex:0] floatValue];
    faceVector.two = [[faceRegion objectAtIndex:1] floatValue];
    faceVector.three = [[faceRegion objectAtIndex:2] floatValue];
    faceVector.four = [[faceRegion objectAtIndex:3] floatValue];
    [_combineFilter setFloatVec4:faceVector forUniform:@"faceRegion"];
}

//Some issue with this method call?
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
