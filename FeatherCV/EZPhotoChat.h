//
//  EZPhotoChat.h
//  FeatherCV
//
//  Created by xietian on 14-5-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessageData.h"

@interface EZPhotoChat : NSObject<JSQMessageData>

@property (nonatomic, strong) NSString* chatID;

@property (nonatomic, strong) NSString* sender;

@property (nonatomic, strong) NSString* text;

@property (nonatomic, strong) NSDate* date;

@property (nonatomic, strong) NSArray* photos;

@property (nonatomic, strong) EZEventBlock success;

@property (nonatomic, strong) EZEventBlock failure;

- (id) initWithSpeaker:(NSString*)sender text:(NSString*)text date:(NSDate*)date chatID:(NSString*)chatID;
//@property (nonatomic, strong) NSString*

- (void) fromJson:(NSDictionary*)dict;

- (NSDictionary*)toJson;

@end
