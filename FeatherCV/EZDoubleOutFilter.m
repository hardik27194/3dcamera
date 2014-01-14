//
//  EZDoubleOutFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-14.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDoubleOutFilter.h"
#import <GPUImageGrayscaleFilter.h>
#import "EZBlackAndCropFilter.h"

@implementation EZDoubleOutFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    _finalFilter = [[GPUImageFilter alloc] init];
    _blackFilter = [[EZBlackAndCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    [self addFilter:_finalFilter];
    [self addFilter:_blackFilter];
    //[self addFilter:_smallBlurFilter];
    self.initialFilters = [NSArray arrayWithObjects:_finalFilter,_blackFilter, nil];
    self.terminalFilter = _finalFilter;
    return self;
}


@end
