//
//  EZConfigure.h
//  3DCamera
//
//  Created by xietian on 14-10-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZConfigure : NSObject

@property (nonatomic, assign) BOOL isWIFIOnly;

@property (nonatomic, assign) CGFloat shotDelay;

@property (nonatomic, assign) BOOL isMute;

@property (nonatomic, assign) int shotCount;

@property (nonatomic, assign) BOOL isPrivate;

@property (nonatomic, strong) NSArray* availableCount;

@property (nonatomic, strong) NSArray* shotDelays;

- (void) loadFromDefault;

- (void) saveToDefault;

SINGLETON_FOR_HEADER(EZConfigure);

@end
