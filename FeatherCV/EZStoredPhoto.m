//
//  EZStoredPhoto.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZStoredPhoto.h"
#import "EZPhotoInfo.h"

@implementation EZStoredPhoto

- (id) init
{
    self = [super init];
    _infos = [[NSMutableArray alloc] init];
    return self;
}

- (void) populate:(NSDictionary*)dict
{
    _remoteURL = [dict objectForKey:@"remoteURL"];
    _taskID = [dict objectForKey:@"taskID"];
    _photoID = [dict objectForKey:@"photoID"];
    _sequence = [[dict objectForKey:@"sequence"] integerValue];
    NSArray* infos = [dict objectForKey:@"infos"];
    for(NSDictionary* infoDict in infos){
        EZPhotoInfo* info = [[EZPhotoInfo alloc] init];
        [info populate:infoDict];
        [_infos addObject:info];
    }
}

@end
