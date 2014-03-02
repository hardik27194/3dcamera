//
//  EZSharpenGaussian.h
//  FeatherCV
//
//  Created by xietian on 14-2-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageGaussianBlurFilter.h"

@interface EZSharpenGaussian : GPUImageGaussianBlurFilter

//0 mean sharpen, 1 mean not
@property (nonatomic, assign) int imageMode;

@end
