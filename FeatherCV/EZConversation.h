//
//  EZConversation.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

//I may need to check the emojj here.
//Why not use the bit which is simple and stupid?
//Just do it.
typedef enum {
    kConversationText,
    kConversationLike,
    kConversationFunny,
    kConversationInteresting
}EZConversationType;

@class EZPerson;
@interface EZConversation : NSObject

@property (nonatomic, assign) int conversationID;

@property (nonatomic, strong) EZPerson* speaker;

@property (nonatomic, strong) NSString* text;

@property (nonatomic, assign) EZConversationType type;

@property (nonatomic, strong) NSDate* date;

@end
