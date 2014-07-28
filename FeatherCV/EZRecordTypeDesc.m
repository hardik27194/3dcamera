//
//  EZRecordTypeDesc.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRecordTypeDesc.h"
#import "EZFileUtil.h"

@implementation EZRecordTypeDesc

- (id) initWith:(NSString*) name type:(EZTrackRecordType)type icon:(NSString*)iconURL blueIcon:(NSString*)blueIcon headerIcon:(NSString *)headerIcon unitName:(NSString *)unitName selected:(BOOL)selected
{
    self = [super init];
    _name = name;
    _type = type;
    _iconURL = iconURL;
    _blueIconURL = blueIcon;
    _headerIcon = headerIcon;
    //_blueIconURL = [EZFileUtil removeFileEnd:iconURL ender:@"_white"];
    EZDEBUG(@"removed :%@", _blueIconURL);
    _unitName = unitName;
    _selected = selected;
    _tmpSelected = selected;
    return self;
}

- (void) setSelected:(BOOL)selected
{
    _selected = selected;
    _tmpSelected = selected;
}

@end
