//
//  EZMenuItem.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMenuItem.h"

@implementation EZMenuItem

- (id) initWith:(NSString*)menuName iconURL:(NSString*)iconURL selectedIconURL:(NSString *)selectedURL action:(EZEventBlock)action
{
    self = [super init];
    _menuName = menuName;
    _iconURL = iconURL;
    _selectedIconURL = selectedURL;
    _selectedAction = action;
    return self;
}

@end
