//
//  EZPhotoInfo.m
//  3DCamera
//
//  Created by xietian on 14-8-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPhotoInfo.h"

@implementation EZPhotoInfo

- (void) populate:(NSDictionary *)dict
{
    _infoID = [dict objectForKey:@"infoID"];
    _photoID = [dict objectForKey:@"photoID"];
    _x = [[dict objectForKey:@"x"] floatValue];
    _y = [[dict objectForKey:@"y"] floatValue];
    _title = [dict objectForKey:@"title"];
    _comment = [dict objectForKey:@"comment"];
    _type = [[dict objectForKey:@"type"] integerValue];
}

- (NSDictionary*) toDict
{
    NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
    if([_infoID isNotEmpty]){
        [res setValue:_infoID forKey:@"infoID"];
    }
    if([_photoID isNotEmpty]){
        [res setValue:_photoID forKey:@"photoID"];
    }
    [res setValue:_title?_title:@"" forKey:@"title"];
    [res setValue:_comment?_comment:@"" forKey:@"comment"];
    [res setValue:@(_x) forKey:@"x"];
    [res setValue:@(_y) forKey:@"y"];
    [res setValue:@(_type) forKey:@"type"];
    return res;
}

@end
