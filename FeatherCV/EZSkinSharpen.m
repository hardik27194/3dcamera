//
//  EZSkinSharpen.m
//  FeatherCV
//
//  Created by xietian on 14-2-22.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSkinSharpen.h"
NSString *const kImageHomeSharpenFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 leftTextureCoordinate;
 varying highp vec2 rightTextureCoordinate;
 varying highp vec2 topTextureCoordinate;
 varying highp vec2 bottomTextureCoordinate;
 
 varying highp float centerMultiplier;
 varying highp float edgeMultiplier;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float sharpenRatio;
 
 const lowp vec3 skinColor = shaderSkinColor;
 
 lowp float calcHue(mediump vec3 rawcolor)
 {
     highp float fd = distance(rawcolor, skinColor);
     if(fd < shaderSkinRange){
         fd = fd;
     }else{
         fd = fd + (fd - shaderSkinRange) * 2.0;
     }
     return min(1.0, fd);
     //return 1.0/(exp((1.5 - distance(rawcolor.rgb, skinColor))) + 1.0);
 }
 
 void main()
 {
     mediump vec4 orgColor = texture2D(inputImageTexture, textureCoordinate);
     mediump vec3 textureColor = orgColor.rgb;
     mediump vec3 leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     mediump vec3 rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     mediump vec3 topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     mediump vec3 bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     
     mediump vec3 sharpGap = textureColor * 4.0 - (leftTextureColor  + rightTextureColor + topTextureColor + bottomTextureColor);
     //highp float sharpDist = distance(sharpGap, sharpGap);
     highp float sharpDist = sqrt(sharpGap.x * sharpGap.x + sharpGap.y * sharpGap.y + sharpGap.z * sharpGap.z);
     
     if(sharpDist < 0.3){
         sharpDist = sharpDist * sharpDist;
     }else{
         sharpDist = sharpDist * sharpDist + (sharpDist - 0.3) * 2.0;
     }
     lowp float colorDist = calcHue(textureColor);
     sharpDist = sharpDist * colorDist * sharpenRatio;
     sharpDist = min(1.0, sharpDist);
    
     highp float centerMt  = 1.0 + 4.0 * sharpDist;
     highp float edgeMt = sharpDist;
     gl_FragColor = vec4((textureColor * centerMt - (leftTextureColor * edgeMt + rightTextureColor * edgeMt + topTextureColor * edgeMt + bottomTextureColor * edgeMt)), orgColor.w);
     //gl_FragColor = vec4(vec3(sharpDist), orgColor.w);//vec4(vec3(sharpLevel), orgColor.w);
    }
 );

@implementation EZSkinSharpen

- (id) init
{
    self = [super initWithFragmentShaderFromString:kImageHomeSharpenFragmentShaderString];
    _sharpenSize = 1.0;
    _sharpenRatio = 0.1;
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    EZDEBUG(@"filter frame size:%@",NSStringFromCGSize(filterFrameSize));
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
        {
            glUniform1f(imageWidthFactorUniform, _sharpenSize * 1.0 / filterFrameSize.height);
            glUniform1f(imageHeightFactorUniform, _sharpenSize * 1.0 / filterFrameSize.width);
        }
        else
        {
            glUniform1f(imageWidthFactorUniform, _sharpenSize * 1.0 / filterFrameSize.width);
            glUniform1f(imageHeightFactorUniform, _sharpenSize * 1.0 / filterFrameSize.height);
        }
    });
}

- (void) setSharpenRatio:(CGFloat)sharpenRatio
{
    [self setFloat:sharpenRatio forUniformName:@"sharpenRatio"];
}

@end
