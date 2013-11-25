//
//  EZStyleImage.m
//  DLCImagePickerController
//
//  Created by xietian on 13-11-11.
//  Copyright (c) 2013年 Backspaces Inc. All rights reserved.
//

#import "EZStyleImage.h"
#import "EZCycleDiminish.h"

@implementation EZStyleImage


//EveryTime, will just add another source image if necessary.
- (void) setImage:(UIImage*)image
{
    if(_sourceImage){
        [_sourceImage removeAllTargets];
    }
    _sourceImage = nil;
    //if(!_sourceImage){
    _sourceImage = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    //}else{
    //    [_sourceImage setImage:image];
    //}
    [self setInputRotation:[self orientation:image] atIndex:0];
    [self setFilters:_filters];
    [self takeEffects];
    //NSLog(@"setImage get called");
}

- (GPUImageRotationMode) orientation:(UIImage*)img
{
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    UIImageOrientation orient = img.imageOrientation;
    switch (orient) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    return imageViewRotationMode;
}

- (void) setFilters:(NSArray *)filters
{
    //[_sourceImage removeAllTargets];
    _filters = filters;
    //NSLog(@"Filters count:%i", filters.count);
    GPUImageOutput* gout = _sourceImage;
    for(id<GPUImageInput> gin in _filters){
        [gout addTarget:gin];
        gout = (GPUImageOutput*)gin;
    }
    [gout addTarget:self];
    //[self takeEffects];
}

+ (EZStyleImage*) createBlurredImage:(CGRect)frame
{
    EZStyleImage* res = [[EZStyleImage alloc] initWithFrame:frame];
    GPUImageGaussianBlurFilter* gaussian = [[GPUImageGaussianBlurFilter alloc] init];
    [res setFilters:@[gaussian]];
    return res;
}

+ (EZStyleImage*) createFilteredImage:(CGRect)frame
{
    EZStyleImage* res = [[EZStyleImage alloc] initWithFrame:frame];
    GPUImageToneCurveFilter* styleCurve = [[GPUImageToneCurveFilter alloc] init];
    [styleCurve setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2226), pointValue(0.5, 0.627), pointValue(0.75, 0.8556), pointValue(1.0, 1.0)]];
    //[styleCurve setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.256), pointValue(0.5, 0.57), pointValue(0.75, 0.795), pointValue(1.0, 1.0)]];
    [styleCurve setRedControlPoints:@[pointValue(0, 0.0442), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.77), pointValue(1.0, 0.977)]]; //
    //[styleCurve setRedControlPoints:@[pointValue(0, 0.017), pointValue(0.25, 0.24), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 0.994)]];
    [styleCurve setGreenControlPoints:@[pointValue(0.0, 0.02), pointValue(0.25, 0.26), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    //[styleCurve setGreenControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    [styleCurve setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2862), pointValue(0.5, 0.48), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    //[styleCurve setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.263), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    
    EZCycleDiminish* vegfilter = [[EZCycleDiminish alloc] init];
    vegfilter.vignetteEnd = 0.73;
    //[vegfilter setVignetteEnd:1.0];
    [res setFilters:@[vegfilter, styleCurve]];
    return res;
}

//Will show the image with effects;
- (void) takeEffects
{
    [_sourceImage processImage];
}

@end
