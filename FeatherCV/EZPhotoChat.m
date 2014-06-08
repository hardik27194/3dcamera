//
//  EZPhotoChat.m
//  FeatherCV
//
//  Created by xietian on 14-5-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPhotoChat.h"
#import "EZDataUtil.h"

@implementation EZPhotoChat

- (id) initWithSpeaker:(NSString*)speakerID text:(NSString*)text date:(NSDate*)createdTime chatID:(NSString*)chatID
{
    self = [super init];
    _sender = speakerID;
    _text = text;
    _date = createdTime;
    _chatID = chatID;
    return self;
}

- (void) fromJson:(NSDictionary*)dict
{
    _chatID = [dict objectForKey:@"chatID"];
    _date = isoStr2Date([dict objectForKey:@"createdTime"]);
    _text = [dict objectForKey:@"text"];
    _sender = [dict objectForKey:@"speakerID"];
    _photos = [dict objectForKey:@"photos"];
}

- (NSDictionary*)toJson
{
    return @{
             @"chatID":_chatID?_chatID:@"",
             @"createdTime":isoDateFormat(_date),
             @"text":_text,
             @"speakerID":_sender,
             @"photos":_photos
             };
}


@end
