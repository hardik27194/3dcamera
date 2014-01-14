//
//  EZBlackAndCropFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-14.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImageFilter.h>

@interface EZBlackAndCropFilter : GPUImageFilter
{
    GLfloat cropTextureCoordinates[8];
}

// The crop region is the rectangle within the image to crop. It is normalized to a coordinate space from 0.0 to 1.0, with 0.0, 0.0 being the upper left corner of the image
@property(readwrite, nonatomic) CGRect cropRegion;

// Initialization and teardown
- (id)initWithCropRegion:(CGRect)newCropRegion;

@end