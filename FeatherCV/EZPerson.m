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
             @"personID":_personID?_personID:@"",
             @"name":_name?_name:@"",
             @"mobile":_mobile?_mobile:@"",
             @"avatar":_avatar?_avatar:@"",
             @"email":_email?_email:@"",
             @"joinedTime":_joinedTime?[[EZDataUtil getInstance].isoFormatter stringFromDate:_joinedTime]:@"",
             @"joined":@(_joined)
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
    if([dict objectForKey:@"joinedTime"]){
        _joinedTime = [[EZDataUtil getInstance].isoFormatter  dateFromString:[dict objectForKey:@"joinedTime"]];
    }
    _joined = [[dict objectForKey:@"joined"] integerValue];
    //return self;
}

@end
