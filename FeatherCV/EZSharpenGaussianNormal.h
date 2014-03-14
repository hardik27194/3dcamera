//
//  EZSharpenGaussianNormal.h
//  FeatherCV
//
//  Created by xietian on 14-3-14.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImageGaussianBlurFilter.h"

@interface EZSharpenGaussianNormal : GPUImageGaussianBlurFilter

//0 mean sharpen, 1 mean not
@property (nonatomic, assign) int imageMode;

@end