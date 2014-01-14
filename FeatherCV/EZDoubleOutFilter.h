//
//  EZDoubleOutFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-14.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImageFilterGroup.h>
@interface EZDoubleOutFilter : GPUImageFilterGroup

@property (nonatomic, strong) GPUImageFilter* finalFilter;

@property (nonatomic, strong) GPUImageFilter* blackFilter;

@end
