//
//  EZThreadUtility.m
//  SchoolCommunity
//
//  Created by xietian on 13-1-14.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZThreadUtility.h"

static EZThreadUtility* sharedPool;

@implementation EZThreadUtility


- (id) init
{
    self = [super init];
    _serialQueue = dispatch_queue_create("my_queue_serial", DISPATCH_QUEUE_SERIAL);
    _concurQueue = dispatch_queue_create("my_queue_concur", DISPATCH_QUEUE_CONCURRENT);
    _gpuQueue = dispatch_queue_create("com.showhair.gpu", nil);
    
    
    _networkQueue = [[NSOperationQueue alloc] init];
    [_networkQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    return self;
}

+ (EZThreadUtility*) getInstance
{
    if(sharedPool == nil){
        sharedPool = [[EZThreadUtility alloc] init];
    }
    
    return sharedPool;
}
//This is for the task not blocking.
//Concurrent mean I hope nothing block in my way.
//System will fork a new thread to process your request if something block in your way.
- (void) executeBlockInQueue:(EZOperationBlock)block  isConcurrent:(BOOL)concurrent
{
    if(concurrent){
        dispatch_async(_concurQueue, block);
    }else{
        dispatch_async(_serialQueue, block);
    }
}


//
- (void) executeBlockInQueue:(EZOperationBlock)block
{
    [self executeBlockInQueue:block isConcurrent:NO];
}

//This make sure will not block current thread
- (void) executeInMain:(EZOperationBlock)block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void) executeOperation:(NSOperation *)opts
{
    [_networkQueue addOperation:opts];
}

@end
