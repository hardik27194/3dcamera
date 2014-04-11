//
//  EZPerson.m
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPerson.h"
#import "EZDataUtil.h"
#import "EZCoreAccessor.h"
@implementation EZPerson

- (id) init
{
    self = [super init];
    _joined = false;
    _joinedTime = [NSDate date];
    return self;
}

- (NSDictionary*) toLocalJson
{
    return @{
             @"personID":null2Empty(_personID),
             @"name":null2Empty(_name),
             @"mobile":null2Empty(_mobile),
             @"avatar":null2Empty(_avatar),
             @"email":null2Empty(_email),
             @"mock":@(_mock),
             @"joinedTime":_joinedTime?isoDateFormat(_joinedTime):@"",
             @"joined":@(_joined),
             @"photoCount":@(_photoCount),
             //@"pendingEventCount":@(_pendingEventCount)
             };

}

- (void) adjustPendingEventCount:(NSInteger)inc
{
    _pendingEventCount += inc;
    if(_pendingEventCount < 0){
        _pendingEventCount = 0;
    }
    
}

- (void) save
{
    _uploaded = true;
    LocalPersons* lp = _localPerson;
    if(_pendingEventCount < 0){
        _pendingEventCount = 0;
    }
    if(lp){
        //EZDEBUG(@"store old persons %@, json:%@", ps.localPerson, [ps toJson]);
        lp.payloads = [self toLocalJson];
    }else{
        lp = [[EZCoreAccessor getClientAccessor] create:[LocalPersons class]];
        _localPerson = lp;
        lp.personID = _personID;
        lp.lastActive = _lastActive;
        lp.mobile = _mobile;
        lp.payloads = [self toLocalJson];
    }
    lp.uploaded = @(_uploaded);

    [[EZCoreAccessor getClientAccessor] saveContext];
}

//Copy other than the pendingEventCount.
- (void) copyValue:(EZPerson*)ps
{
    _personID = ps.personID;
    _name = ps.name;
    _mobile = ps.mobile;
    _avatar = ps.avatar;
    _email = ps.email;
    _photoCount = ps.photoCount;
    _isFriend = ps.isFriend;
    _joined = ps.joined;
    _mock = ps.mock;
    //_pendingEventCount = ps.pendingEventCount;
    _joinedTime = ps.joinedTime;
}


- (void) fromLocalJson:(NSDictionary *)dict
{
    _personID = [dict objectForKey:@"personID"];
    _name = [dict objectForKey:@"name"];
    _mobile = [dict objectForKey:@"mobile"];
    _avatar = [dict objectForKey:@"avatar"];
    _email = [dict objectForKey:@"email"];
    _photoCount = [[dict objectForKey:@"photoCount"] integerValue];
    _isFriend = [[dict objectForKey:@"isFriend"] integerValue];
    if([dict objectForKey:@"joinedTime"]){
        _joinedTime = [[EZDataUtil getInstance].isoFormatter  dateFromString:[dict objectForKey:@"joinedTime"]];
    }
    _joined = [[dict objectForKey:@"joined"] integerValue];
    _mock = [[dict objectForKey:@"mock"] integerValue];
    //_pendingEventCount = [[dict objectForKey:@"pendingEventCount"] integerValue];

}

- (NSDictionary*) toJson
{
    return @{
             @"personID":null2Empty(_personID),
             @"name":null2Empty(_name),
             @"mobile":null2Empty(_mobile),
             @"avatar":null2Empty(_avatar),
             @"email":null2Empty(_email),
             @"mock":@(_mock),
             @"joinedTime":_joinedTime?isoDateFormat(_joinedTime):@"",
             @"joined":@(_joined),
             @"photoCount":@(_photoCount)
             };
}


- (void) fromJson:(NSDictionary*)dict
{
    //self = [super init];
    _personID = [dict objectForKey:@"personID"];
    _name = [dict objectForKey:@"name"];
    _mobile = [dict objectForKey:@"mobile"];
    _avatar = [dict objectForKey:@"avatar"];
    _email = [dict objectForKey:@"email"];
    _photoCount = [[dict objectForKey:@"photoCount"] integerValue];
    _isFriend = [[dict objectForKey:@"isFriend"] integerValue];
    if([dict objectForKey:@"joinedTime"]){
        _joinedTime = [[EZDataUtil getInstance].isoFormatter  dateFromString:[dict objectForKey:@"joinedTime"]];
    }
    _joined = [[dict objectForKey:@"joined"] integerValue];
    _mock = [[dict objectForKey:@"mock"] integerValue];
    //return self;
}

@end
