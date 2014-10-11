//
//  EZMessageCenter.h
//  SchoolCommunity
//
//  Created by xietian on 13-1-25.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZConstants.h"

@interface EZMessageCenter : NSObject

@property (nonatomic, strong) NSMutableDictionary* registeredEvent;

@property (nonatomic, strong) NSMutableDictionary* keyedBlocks;

//For the event will keep until some reieved it.
@property (nonatomic, strong) NSMutableDictionary* pendingEvent;

+ (EZMessageCenter*) getInstance;

- (void) registerEvent:(NSString*)eventName block:(EZEventBlock)block isWeak:(BOOL)isWeak;

- (void) registerEvent:(NSString*)eventName block:(EZEventBlock)block;

- (void) registerEvent:(NSString*)eventName block:(EZEventBlock)block withKey:(NSString*)key;

- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block once:(BOOL)once isWeak:(BOOL)isWeak;


//If as pending event for me
//Only for event that nobody recieved yets
- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block loadPending:(BOOL)loadPending;



- (void) unregisterWithKey:(NSString*)key;


- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block once:(BOOL)once;

- (void) registerRetryEvent:(NSString*)eventName block:(EZRetryBlock)block;

- (void) unregisterEvent:(NSString*)eventName;

//Now allow multiple listener to listen for one event.
- (void) unregisterEvent:(NSString *)eventName forObject:(id)object;

//Make sure it execute in the main thread.
- (void) postEvent:(NSString*)message attached:(id)object;

//The event will be executed directly. no more tricks. 
- (void) postEvent:(NSString*)message attached:(id)object direct:(BOOL)direct;

- (void) postEvent:(NSString *)message attached:(id)object direct:(BOOL)direct pending:(BOOL)pending;

@end
