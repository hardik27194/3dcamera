//
//  EZRecordTypeDesc.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRecordTypeDesc.h"
#import "EZFileUtil.h"

#define iconTemplate(src)  [NSString stringWithFormat:@"icon_%@_white.png", src]

#define headerIconTemplate(src) [NSString stringWithFormat:@"header_icon_%@_white.png", src]

#define blueIconTemplate(src) [NSString stringWithFormat:@"icon_%@.png", src]

@implementation EZRecordTypeDesc




- (id) initWith:(NSString*)name type:(EZTrackRecordType)type source:(NSString*)source unitName:(NSString*)unitName  selected:(BOOL)selected;
{
    self = [super init];
    _name = name;
    _type = type;
    _iconURL = bundle2url(iconTemplate(source));
    _blueIconURL = bundle2url(blueIconTemplate(source));
    _headerIcon = bundle2url(headerIconTemplate(source));
    //EZDEBUG(@"iconURL:%@", _iconURL);
    //_blueIconURL = [EZFileUtil removeFileEnd:iconURL ender:@"_white"];
    //EZDEBUG(@"removed :%@", _blueIconURL);
    _source = source;
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
