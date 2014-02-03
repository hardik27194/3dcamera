//
//  EZSkinMaskFilter.h
//  FeatherCV
//
//  Created by xietian on 14-2-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageFilter.h"

@interface EZSkinMaskFilter : GPUImageFilter

@property (nonatomic, strong) NSArray* faceRegion;

@property (nonatomic, assign) CGFloat faceThreshold;

@end
