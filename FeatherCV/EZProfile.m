//
//  EZProfile.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZProfile.h"

@implementation EZProfile

- (id) initWith:(NSString*)name type:(EZProfileType)type avatar:(NSString*)avatar
{
    self = [super init];
    
    _name = name;
    _type = type;
    _avartar = avatar;
    
    return self;
}

@end
