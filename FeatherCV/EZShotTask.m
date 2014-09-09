//
//  EZShotTask.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShotTask.h"
#import "EZStoredPhoto.h"
#import "LocalTasks.h"
#import "EZCoreAccessor.h"

@implementation EZShotTask

- (id) init
{
    self = [super init];
    _photos = [[NSMutableArray alloc] init];
    _shotDate = [NSDate date];
    return self;
}

- (void) populateTask:(NSDictionary *)dict
{
    _taskID = [dict objectForKey:@"taskID"];
    _name = [dict objectForKey:@"name"];
    _personID = [dict objectForKey:@"personID"];
    NSArray* photos = [dict objectForKey:@"photos"];
    for(NSDictionary* pt in photos){
        EZStoredPhoto* storedPhoto = [[EZStoredPhoto alloc] init];
        [storedPhoto populate:pt];
        [_photos addObject:storedPhoto];
    }
}

//The file will get deleted in this method too
- (void) deleteLocal
{
    if(_localTask){
        [_localTask.managedObjectContext deleteObject:_localTask];
    }
}

- (NSDictionary*) toDict
{
    NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
    [res setObject:_taskID forKey:@"taskID"];
    [res setObject:_name?_name:@"" forKey:@"name"];
    [res setObject:_personID forKey:@"personID"];
    NSMutableArray* photoArr = [[NSMutableArray alloc] init];
    for(EZStoredPhoto* storePhoto in _photos){
        [photoArr addObject:[storePhoto toDict]];
    }
    [res setObject:photoArr forKey:@"photos"];
    
    return res;
}

- (void) store
{
    LocalTasks* lp = _localTask;
    if(lp){
        //EZDEBUG(@"store old persons %@, json:%@", ps.localPerson, [ps toJson]);
        lp.personID = _personID;
        lp.taskID = _taskID;
        //lp.createdTime =
        lp.payload = [self toDict];
    }else{
        lp = [[EZCoreAccessor getClientAccessor] create:[LocalTasks class]];
        _localTask = lp;
        lp.personID = _personID;
        lp.createdTime = _shotDate;
        //lp.mobile = _mobile;
        lp.taskID = _taskID;
        lp.payload = [self toDict];
    }
    //lp.uploaded = @(_uploaded);
    [[EZCoreAccessor getClientAccessor] saveContext];
}


@end

