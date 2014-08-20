//
//  EZShotTask.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShotTask.h"
#import "EZStoredPhoto.h"

@implementation EZShotTask

- (id) init
{
    self = [super init];
    _photos = [[NSMutableArray alloc] init];
    return self;
}

- (void) populateTask:(NSDictionary *)dict
{
    _taskID = [dict objectForKey:@"taskID"];
    _name = [dict objectForKey:@"name"];
    NSArray* photos = [dict objectForKey:@"photos"];
    for(NSDictionary* pt in photos){
        EZStoredPhoto* storedPhoto = [[EZStoredPhoto alloc] init];
        [storedPhoto populate:pt];
        [_photos addObject:storedPhoto];
    }
}

@end

