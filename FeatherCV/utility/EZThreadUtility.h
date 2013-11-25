//
//  EZThreadUtility.h
//  SchoolCommunity
//
//  Created by xietian on 13-1-14.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZConstants.h"

@interface EZThreadUtility : NSObject

+ (EZThreadUtility*) getInstance;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurQueue;
@property (nonatomic, strong) NSOperationQueue* networkQueue;

//I suspect the crash was caused by the thread collision.
@property (nonatomic, strong) dispatch_queue_t gpuQueue;

//The first step to adopt to GCD
- (void) executeBlockInQueue:(EZOperationBlock)block;

- (void) executeBlockInQueue:(EZOperationBlock)block isConcurrent:(BOOL)concurrent;

- (void) executeOperation:(NSOperation*)opts;

- (void) executeInMain:(EZOperationBlock)block;

@end
