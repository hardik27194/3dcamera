//
//  EZSkinSharpen.h
//  FeatherCV
//
//  Created by xietian on 14-2-22.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageSharpenFilter.h"

@interface EZSkinSharpen : GPUImageSharpenFilter

@property (nonatomic, assign) CGFloat sharpenSize;

@property (nonatomic, assign) CGFloat sharpenRatio;

@end
