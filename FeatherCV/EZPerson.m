//
//  EZPerson.m
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPerson.h"
#import "EZDataUtil.h"
@implementation EZPerson

- (id) init
{
    self = [super init];
    _joined = false;
    _joinedTime = [NSDate date];
    return self;
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
