//
//  EZStyleImage.h
//  DLCImagePickerController
//
//  Created by xietian on 13-11-11.
//  Copyright (c) 2013年 Backspaces Inc. All rights reserved.
//

#import "GPUImage.h"

//I will have my own waiting effects in this method.
//For the AFNetwork, in next iteration, I will find my own download ready and cache notification mechanism.
//Cool


@interface EZStyleImage : GPUImageView

@property (nonatomic, strong) GPUImagePicture* sourceImage;

@property (nonatomic, strong) NSArray* filters;

//EveryTime, will just add another source image if necessary.
- (void) setImage:(UIImage*)image;

- (void) takeEffects;

+ (EZStyleImage*) createBlurredImage:(CGRect)frame;

+ (EZStyleImage*) createFilteredImage:(CGRect)frame;

@end
