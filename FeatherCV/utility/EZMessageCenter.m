//
//  EZMessageCenter.m
//  SchoolCommunity
//
//  Created by xietian on 13-1-25.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZMessageCenter.h"


@interface EZBlockHolder : NSObject

@property (nonatomic, strong) id block;

@property (nonatomic, strong) id strongBlock;

@property (nonatomic, weak) id weakBlock;

@property (nonatomic, assign) BOOL isOnce;

//Whether this block is a retry block.
@property (nonatomic, assign) BOOL isRetry;

@property (nonatomic, strong) id retryBlock;

@property (nonatomic, assign) BOOL isWeak;

+ (EZBlockHolder*) hold:(id)block once:(BOOL)once;

+ (EZBlockHolder*) hold:(id)block once:(BOOL)once isWeak:(BOOL)isWeak;

@end

@implementation EZBlockHolder

+ (EZBlockHolder*) hold:(id)block once:(BOOL)once
{
    return [self hold:block once:once isWeak:NO];
}

+ (EZBlockHolder*) hold:(id)block once:(BOOL)once isWeak:(BOOL)isWeak
{
    EZBlockHolder* res = [[EZBlockHolder alloc] init];
    res.isWeak = isWeak;
    res.block = block;
    res.isOnce = once;
    return res;
}

- (void) setBlock:(id)block
{
    if(_isWeak){
        _weakBlock = block;
    }else{
        _strongBlock = block;
    }
}

- (id) getBlock
{
    EZDEBUG(@"get block called");
    if(_isWeak){
        return _weakBlock;
    }
    return _strongBlock;
}

@end


EZMessageCenter* instance = nil;

@implementation EZMessageCenter

+ (EZMessageCenter*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZMessageCenter alloc] init];
    });
    return instance;
}

- (id) init
{
    self = [super init];
    _registeredEvent = [[NSMutableDictionary alloc] init];
    _keyedBlocks = [[NSMutableDictionary alloc] init];
    _pendingEvent = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) firePending:(NSString*)eventName
{
    NSArray* pendingEvent = [_pendingEvent objectForKey:eventName];
    EZDEBUG(@"Pending event count:%i", pendingEvent.count);
    [_pendingEvent removeObjectForKey:eventName];
    for(id obj in pendingEvent){
        id postObj = obj;
        if([obj isKindOfClass:[NSNull class]]){
            postObj = nil;
        }
        [self postEvent:eventName attached:postObj];
    }
}

- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block loadPending:(BOOL)loadPending
{
    [self registerEvent:eventName block:block];
    if(loadPending){
        [self firePending:eventName];
    }
}


- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block withKey:(NSString *)key
{
    EZEventBlock blk = block;
    NSMutableArray* blocks = [_keyedBlocks objectForKey:key];
    if(!blocks){
        blocks = [[NSMutableArray alloc] init];
        [_keyedBlocks setValue:blocks forKey:key];
    }
    [blocks addObject:@{@"block":blk, @"event":eventName}];
    [self registerEvent:eventName block:blk];
}

- (void) unregisterWithKey:(NSString *)key
{
    NSArray* blocks = [_keyedBlocks objectForKey:key];
    [_keyedBlocks removeObjectForKey:key];    
    for(NSDictionary* bk in blocks){
        EZDEBUG(@"Event name:%@, block:%i", [bk objectForKey:@"event"], (int)[bk objectForKey:@"block"]);
        [self unregisterEvent:[bk objectForKey:@"event"] forObject:[bk objectForKey:@"block"]];
    }
}

- (void) registerEvent:(NSString*)eventName block:(EZEventBlock)block isWeak:(BOOL)isWeak
{
    [self registerEvent:eventName block:block once:false isWeak:isWeak];
    //[_registeredEvent setValue:block forKey:eventName];
}



- (void) registerEvent:(NSString*)eventName block:(EZEventBlock)block
{
    [self registerEvent:eventName block:block once:false];
    //[_registeredEvent setValue:block forKey:eventName];
}

- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block once:(BOOL)once
{
    [self registerEvent:eventName block:block once:once isWeak:false];
}

- (void) registerEvent:(NSString *)eventName block:(EZEventBlock)block once:(BOOL)once isWeak:(BOOL)isWeak;
{
    NSMutableArray* listeners = [_registeredEvent objectForKey:eventName];
    if(listeners == nil){
        listeners = [[NSMutableArray alloc] init];
        [_registeredEvent setValue:listeners forKey:eventName];
    }
    [listeners addObject:[EZBlockHolder hold:block once:once isWeak:isWeak]];
}


- (void) registerRetryEvent:(NSString*)eventName block:(EZRetryBlock)block
{
    NSMutableArray* listeners = [_registeredEvent objectForKey:eventName];
    if(listeners == nil){
        listeners = [[NSMutableArray alloc] init];
        [_registeredEvent setValue:listeners forKey:eventName];
    }
    EZBlockHolder* bh = [EZBlockHolder hold:block once:NO];
    bh.isRetry = YES;
    __weak EZMessageCenter* weakSelf = self;
    bh.retryBlock = ^(){
        [weakSelf registerRetryEvent:eventName block:block];
    };
    [listeners addObject:bh];
}

- (void) unregisterEvent:(NSString*)eventName
{
    [_registeredEvent removeObjectForKey:eventName];
}


- (void) unregisterEvent:(NSString *)eventName forObject:(id)object
{
    NSMutableArray* blocks = [_registeredEvent objectForKey:eventName];
    EZDEBUG(@"Before remove:%i", blocks.count);
    //[blocks removeObject:object];
    for(int i = 0; i < blocks.count; i++){
        EZBlockHolder* bh = [blocks objectAtIndex:i];
        EZDEBUG(@"block pointer:%i, isWeak:%i, %i", (int)bh.block, bh.isWeak, (int)bh.strongBlock);
        if((int)bh.getBlock == (int)object){
            [blocks removeObjectAtIndex:i];
            break;
        }
    }
    EZDEBUG(@"After remove:%i", blocks.count);
    
}

- (void) postEvent:(NSString*)message attached:(id)object
{
    [self postEvent:message attached:object direct:false];
}

- (void) postEvent:(NSString *)message attached:(id)object direct:(BOOL)direct pending:(BOOL)pending
{
    NSMutableArray* blocks = [_registeredEvent objectForKey:message];
    EZDEBUG(@"Find block for:%@", message);
    if(pending && blocks.count == 0){
        NSMutableArray* ma = [_pendingEvent objectForKey:message];
        if(ma == nil){
            ma = [[NSMutableArray alloc] init];
            [_pendingEvent setValue:ma forKey:message];
        }
        if(object){
            [ma addObject:object];
        }else{
            [ma addObject:[NSNull null]];
        }
    }
    
    NSArray* iterator = [NSArray arrayWithArray:blocks];
    for(EZBlockHolder* blockHolder in iterator){
        if(blockHolder.isOnce || blockHolder.isRetry){
            [blocks removeObject:blockHolder];
        }
        EZOperationBlock action = ^()
        {
            if(blockHolder.isRetry){
                EZRetryBlock reBlock = (EZRetryBlock)blockHolder.getBlock;
                reBlock(object, blockHolder.retryBlock);
            }else{
                EZEventBlock eb = (EZEventBlock)blockHolder.getBlock;
                eb(object);
            }
            
        };
        
        if(blockHolder.getBlock){
            if(!direct){
                dispatch_async(dispatch_get_main_queue(),action);
            }else{
                action();
            }
        }else{
            EZDEBUG(@"remove weak block");
            [blocks removeObject:blockHolder];
        }
    }

}


//Make sure it execute in the main thread.
- (void) postEvent:(NSString*)message attached:(id)object direct:(BOOL)direct
{
    [self postEvent:message attached:object direct:direct pending:NO];
}

@end
