//
//  EZTouch.h
//  FeatherCV
//
//  Created by xietian on 14-7-15.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

//The class represent the touchs
@class EZPerson;
@interface EZTouch : NSObject

@property (nonatomic, strong) NSArray* touches;

@property (nonatomic, strong) EZPerson* toucher;

@property (nonatomic, strong) EZPerson* touchee;

@property (nonatomic, strong) NSDate* createdTime;

@end
