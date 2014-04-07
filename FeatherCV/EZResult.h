//
//  EZResult.h
//  FeatherCV
//
//  Created by xietian on 14-4-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

//Why have this result, make the interface clear and straightforward
@interface EZResult : NSObject

@property (nonatomic, assign) int totalCount;

@property (nonatomic, strong) NSArray* result;

- (id) initWithCount:(int)totalCount array:(NSArray*)array;

@end
