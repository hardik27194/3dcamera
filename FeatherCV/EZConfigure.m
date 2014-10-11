//
//  EZConfigure.m
//  3DCamera
//
//  Created by xietian on 14-10-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZConfigure.h"

@implementation EZConfigure

- (id) init
{
    self = [super init];
    _availableCount = @[@"6", @"8",@"12", @"16", @"24", @"36", @"48", @"64"];
    _shotDelays = @[@"2",@"3",@"4",@"6",@"9",@"12",@"18",@"24",@"36",@"60"];
    [self loadFromDefault];
    return self;
}

- (void) loadFromDefault
{
    _isWIFIOnly = [[NSUserDefaults standardUserDefaults] boolForKey:@"isWIFIOnly"];
    _isPrivate = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPrivate"];
    _isMute = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMute"];
    _shotCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"shotCount"];
    if(_shotCount == 0){
        _shotCount = 6;
    }
    _shotDelay = [[NSUserDefaults standardUserDefaults] floatForKey:@"shotDelay"];
    if(_shotDelay == 0){
        _shotDelay = 3;
    }
}


- (void) saveToDefault
{
    [[NSUserDefaults standardUserDefaults] setBool:_isWIFIOnly forKey:@"isWIFIOnly"];
    [[NSUserDefaults standardUserDefaults] setBool:_isPrivate forKey:@"isPrivate"];
    [[NSUserDefaults standardUserDefaults] setBool:_isMute forKey:@"isMute"];
    [[NSUserDefaults standardUserDefaults] setInteger:_shotCount forKey:@"shotCount"];
    [[NSUserDefaults standardUserDefaults] setFloat:_shotDelay forKey:@"shotDelay"];
}

SINGLETON_FOR_CLASS(EZConfigure);

@end
