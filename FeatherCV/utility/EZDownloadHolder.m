//
//  EZDownloadHolder.m
//  FeatherCV
//
//  Created by xietian on 14-3-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDownloadHolder.h"

@implementation EZDownloadHolder

- (id) init
{
    self = [super init];
    _success = [[NSMutableArray alloc] init];
    _failures = [[NSMutableArray alloc] init];
    return self;
}

- (void) insertSuccess:(EZEventBlock)block
{
    if(block){
        [_success addObject:block];
    }
}

- (void) insertFailure:(EZEventBlock)block
{
    if(block){
        [_failures addObject:block];
    }
}

- (void) callSuccess
{
    NSArray* successes = [NSArray arrayWithArray:_success];
    [_success removeAllObjects];
    EZDEBUG(@"download success size:%i", successes.count);
    for(EZEventBlock block in successes){
        block(_downloaded);
    }
    [self cleanAllPending];
}

- (void) cleanAllPending
{
    [_failures removeAllObjects];
    [_success removeAllObjects];
}

- (void) callFailure:(id)failure
{
    NSArray* fails = [NSArray arrayWithArray:_failures];
    [_failures removeAllObjects];
    for(EZEventBlock block in fails){
        block(failure);
    }
    [self cleanAllPending];
}

@end
