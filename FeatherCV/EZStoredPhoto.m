//
//  EZStoredPhoto.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZStoredPhoto.h"

@implementation EZStoredPhoto

- (void) populate:(NSDictionary*)dict
{
    _remoteURL = [dict objectForKey:@"remoteURL"];
    _taskID = [dict objectForKey:@"taskID"];
    _photoID = [dict objectForKey:@"photoID"];
    _sequence = [[dict objectForKey:@"sequence"] integerValue];
}

@end
