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
 //varying highp vec2 textureCoordinate3;
 
 //small blur
 //varying highp vec2 textureCoordinate4;
 
//varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 //uniform sampler2D inputImageTexture3;
 //uniform sampler2D inputImageTexture4;
 //uniform lowp vec3 skinColor;
 uniform lowp vec4 faceRegion;
 
 uniform lowp float blurRatio;
 uniform lowp float edgeRatio;
 uniform lowp int imageMode;
 uniform lowp int showFace;
 uniform lowp float miniRealRatio;
 uniform lowp float maxRealRatio;
 uniform lowp int skinColorFlag;
 
 const lowp vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
 const lowp vec4  kRGBToI     = vec4 (0.595716, -0.274453, -0.321263, 0.0);
 const lowp vec4  kRGBToQ     = vec4 (0.211456, -0.522591, 0.31135, 0.0);
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 const lowp vec3  skinColor = shaderSkinColor;
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
 
 lowp float calcHue(lowp vec4 rawcolor,lowp vec3 skColor)
 {
     highp float fd = distance(rawcolor.rgb, skColor);
     highp float base = distance(blueShaderColor, skColor);
     fd = fd / base;
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 lowp float calcLineDist(lowp vec4 rawcolor)
 {
     highp float fd = distance(rawcolor.rgb, skinColor);
     if(fd < 0.42){
         fd = fd * 3.0;
     }else{
         fd = fd * 1.5;//1.0/(exp(-fd * 8.0) + 1.0);
     }
     return fd;
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     //lowp vec4 smallBlurColor = texture2D(inputImageTexture3, textureCoordinate3);
     //lowp vec4 detectedEdge = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);

     //lowp float finalEdgeRatio = detectedEdge.r;
     /**
     if(showFace == 1 && textureCoordinate.x > faceRegion.x && textureCoordinate.x < faceRegion.y && textureCoordinate.y > faceRegion.z && textureCoordinate.y < faceRegion.w){
         gl_FragColor = sharpImageColor * 0.3;
     }else{
         gl_FragColor = sharpImageColor;
     }
      **/
     if(imageMode == 0){
         lowp vec3 skColor = shortShaderSkinColor;
         if(skinColorFlag == 1){
             skColor = longShaderSkinColor;
         }
         lowp float colorDist = calcHue(blurredImageColor, skColor);
         lowp float middleStart = 0.5;
         //if(colorDist < 0.5){
         //    colorDist = colorDist * 0.5;
         //}else{
         //    colorDist = 0.25 + (colorDist - 0.5) * 1.5;
         //}
         lowp float changeGap =miniRealRatio + (maxRealRatio - miniRealRatio) * colorDist;
         
         gl_FragColor = changeGap * sharpImageColor +  (1.0 - changeGap) * (sharpImageColor*blurRatio + (1.0 - blurRatio)*blurredImageColor);
     //gl_FragColor = blurredImageColor;
     }else if(imageMode == 1){
         gl_FragColor = blurredImageColor;
     }else if(imageMode == 2){
         gl_FragColor = sharpImageColor;
     }else if(imageMode == 3){
         gl_FragColor = vec4(vec3(0.0),1.0);
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
    
    _sharpGaussian = [[EZSharpenGaussian alloc] init];
    //_sharpenFilter = [[EZSkinSharp]]
    //[[EZSkinBrighter alloc] init];
    //[_skinBrighter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.125), pointValue(0.25, 0.31), pointValue(0.5, 0.545), pointValue(0.75, 0.785), pointValue(1.0, 1.0)]];
    //[_skinBrighter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.13), pointValue(0.25, 0.26), pointValue(0.5, 0.51), pointValue(0.75, 0.76), pointValue(1.0, 0.99)]];
    //[_skinBrighter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.118), pointValue(0.25, 0.243), pointValue(0.5, 0.493), pointValue(0.75, 0.743), pointValue(1.0, 0.995)]];
    //[_skinBrighter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.130), pointValue(0.25, 0.255), pointValue(0.5, 0.505), pointValue(0.75, 0.755), pointValue(1.0, 1.0)]];
    //[_skinBrighter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.120), pointValue(0.25, 0.245), pointValue(0.5, 0.495), pointValue(0.75, 0.745), pointValue(1.0, 1.0)]];
    //_edgeBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    //blurFilter.blurSize = 2.0;
    //_blurFilter.blurSize = 5.0;
    //[self addFilter:_blurFilter];
    //[self addFilter:_smallBlurFilter];
    //_edgeFilter = [[EZHomeEdgeFilter alloc] init];
    //[self addFilter:_edgeFilter];
    //[_edgeFilter addTarget:_edgeBlurFilter];
    // Second pass: combine the blurred image with the original sharp one
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    
    //_sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    //_sharpenFilter.sharpness = 0.3;
    //[self addTarget:_sharpenFilter];
    //[_sharpenFilter addTarget:_blurFilter];
    [self addTarget:_sharpGaussian];
    [_sharpGaussian addTarget:_blurFilter];
    [self addTarget:_combineFilter];
    //[_edgeFilter addTarget:_combineFilter atTextureLocation:1];
    //[_skinBrighter addTarget:_combineFilter atTextureLocation:0];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    //[_smallBlurFilter addTarget:_combineFilter atTextureLocation:2];
    //[_edgeFilter addTarget:_combineFilter atTextureLocation:3];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    //[_combineFilter disableSecondFrameCheck];
    self.initialFilters = [NSArray arrayWithObjects:_sharpGaussian, _combineFilter, nil];
    //self.skinColors = @[@(1.0),@(0.75),@(0.58)];
    self.terminalFilter = _combineFilter;
    //self.edgeRatio =
    self.imageMode = 0;
    return self;
}


- (id) initSimple
{
    if (!(self = [super init]))
    {
		return nil;
    }
    hasOverriddenAspectRatio = NO;
    _blurFilter = [[EZHomeBiBlur alloc] init];
    _sharpGaussian = [[EZSharpenGaussian alloc] init];
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    return self;
}

- (id)initWithFilters:(NSArray*)outfilters;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    hasOverriddenAspectRatio = NO;
    _blurFilter = [[EZHomeBiBlur alloc] init];
    _sharpGaussian = [[EZSharpenGaussian alloc] init];
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    self.blendFilters = outfilters;
    return self;
}

- (id) initWithFilter:(GPUImageFilter*)filter
{
    self = [super init];
    EZDEBUG(@"setup blend filers");
    hasOverriddenAspectRatio = NO;
    _blurFilter = [[EZHomeBiBlur alloc] init];
    //_sharpGaussian = [[EZSharpenGaussian alloc] init];
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    //_sharpGaussian = [[EZSharpenGaussian alloc] init];
    //[self addTarget:filter];
    
    //[self addTarget:_sharpGaussian];
    [self addTarget:_combineFilter];
    
    [self addTarget:filter];
    //[filter addTarget:_sharpGaussian];
    [filter addTarget:_blurFilter];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    self.initialFilters = [NSArray arrayWithObjects:filter, _combineFilter, nil];
    //self.skinColors = @[@(1.0),@(0.75),@(0.58)];
    self.terminalFilter = _combineFilter;
    self.imageMode = 0;
    return self;

}

- (id) initWithSharpen
{
    EZDEBUG(@"setup blend filers");
    hasOverriddenAspectRatio = NO;
    _blurFilter = [[EZHomeBiBlur alloc] init];
    _sharpGaussian = [[EZSharpenGaussian alloc] init];
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    [self addTarget:_sharpGaussian];
    //[tongFilter addTarget:_sharpGaussian];
    [_sharpGaussian addTarget:_blurFilter];
    [self addTarget:_combineFilter];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    self.initialFilters = [NSArray arrayWithObjects:_sharpGaussian, _combineFilter, nil];
    //self.skinColors = @[@(1.0),@(0.75),@(0.58)];
    self.terminalFilter = _combineFilter;
    self.imageMode = 0;
    return self;
}

- (id) initWithTongFilter:(GPUImageToneCurveFilter*)tongFilter
{
    EZDEBUG(@"setup blend filers");
    hasOverriddenAspectRatio = NO;
    _blurFilter = [[EZHomeBiBlur alloc] init];
    _sharpGaussian = [[EZSharpenGaussian alloc] init];
    _combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kHomeBlendFragmentShaderString];
    _tongFilter = tongFilter;
    [self addTarget:tongFilter];
    [tongFilter addTarget:_sharpGaussian];
    [_sharpGaussian addTarget:_blurFilter];
    [self addTarget:_combineFilter];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    self.initialFilters = [NSArray arrayWithObjects:tongFilter, _combineFilter, nil];
    //self.skinColors = @[@(1.0),@(0.75),@(0.58)];
    self.terminalFilter = _combineFilter;
    self.imageMode = 0;
    return self;
}

- (void) removeMyTargets
{
    [super removeAllTargets];
    [_blurFilter removeAllTargets];
    [_sharpGaussian removeAllTargets];
    [_combineFilter removeAllTargets];
}

- (void) setBlendFilters:(NSArray*)outfilters
{
    _blendFilters = outfilters;
    // Second pass: combine the blurred image with the original sharp one
    //[self removeAllTargets];
    [self removeMyTargets];
    EZDEBUG(@"setup blend filers");
    
    GPUImageFilter* currentFilter = [outfilters objectAtIndex:0];
    GPUImageFilter* firstFilter = currentFilter;
    [self addTarget:firstFilter];
    for(int i = 1; i < outfilters.count; i ++){
        GPUImageFilter* gf = [outfilters objectAtIndex:i];
        [currentFilter addTarget:gf];
        currentFilter = gf;
    }
    [currentFilter addTarget:_sharpGaussian];
    [_sharpGaussian addTarget:_blurFilter];
    [self addTarget:_combineFilter];
    [_blurFilter addTarget:_combineFilter atTextureLocation:1];
    self.initialFilters = [NSArray arrayWithObjects:firstFilter, _combineFilter, nil];
    //self.skinColors = @[@(1.0),@(0.75),@(0.58)];
    self.terminalFilter = _combineFilter;
    self.imageMode = 0;
}

- (void) setBlurRatio:(CGFloat)blurRatio
{
    [_combineFilter setFloat:blurRatio forUniformName:@"blurRatio"];
}

- (void) setEdgeRatio:(CGFloat)edgeRatio
{
    [_combineFilter setFloat:edgeRatio forUniformName:@"edgeRatio"];
}

- (void) setMiniRealRatio:(CGFloat)miniRealRatio
{
    _miniRealRatio = miniRealRatio;
    [_combineFilter setFloat:miniRealRatio forUniformName:@"miniRealRatio"];
}

- (void) setMaxRealRatio:(CGFloat)maxRealRatio
{
    _maxRealRatio = maxRealRatio;
    [_combineFilter setFloat:_maxRealRatio forUniformName:@"maxRealRatio"];
}

- (void) setImageMode:(int)imageMode
{
    _imageMode = imageMode;
    [_combineFilter setInteger:imageMode forUniformName:@"imageMode"];
}

/**
- (void) setSkinColors:(NSArray *)skinColors
{
    GPUVector3 skinColor;
    skinColor.one = [[skinColors objectAtIndex:0] floatValue];
    skinColor.two = [[skinColors objectAtIndex:1] floatValue];
    skinColor.three = [[skinColors objectAtIndex:2] floatValue];
    _skinColors = skinColors;
    [_combineFilter setFloatVec3:skinColor forUniformName:@"skinColor"];
}
**/

- (void) setSkinColorFlag:(int)skinColorFlag
{
    _skinColorFlag = skinColorFlag;
    [_combineFilter setInteger:skinColorFlag forUniformName:@"skinColorFlag"];
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
