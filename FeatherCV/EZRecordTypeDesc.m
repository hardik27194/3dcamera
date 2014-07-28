//
//  EZRecordTypeDesc.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRecordTypeDesc.h"

@implementation EZRecordTypeDesc

- (id) initWith:(NSString*) name type:(EZTrackRecordType)type icon:(NSString*)iconURL unitName:(NSString*)unitName  selected:(BOOL)selected
{
    self = [super init];
    _name = name;
    _type = type;
    _iconURL = iconURL;
    _unitName = unitName;
    _selected = selected;
    return self;
}

@end
