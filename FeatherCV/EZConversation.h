//
//  EZConversation.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZConversation : NSObject

@property (nonatomic, assign) int conversationID;
@property (nonatomic, assign) int speakerID;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSDate* createdTime;

@end
