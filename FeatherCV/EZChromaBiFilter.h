//
//  EZChromaBiFilter.h
//  FeatherCV
//
//  Created by xietian on 14-2-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "GPUImageBilateralFilter.h"

@interface EZChromaBiFilter : GPUImageBilateralFilter

//0 mean transfer the L
//1 mena transfer the AB
@property (nonatomic, assign) int imageMode;

@end
