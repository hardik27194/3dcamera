//
//  EZResult.m
//  FeatherCV
//
//  Created by xietian on 14-4-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZResult.h"

@implementation EZResult

- (id) initWithCount:(int)totalCount array:(NSArray*)array
{
    self = [super init];
    _result = array;
    _totalCount = totalCount;
    return self;
}

@end
