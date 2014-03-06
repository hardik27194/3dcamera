//
//  EZChatUnit.h
//  FeatherCV
//
//  Created by xietian on 14-3-1.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZClickImage;
//This one will handle all the chat display
@interface EZChatUnit : UIView

@property (nonatomic, strong) UILabel* chatText;

@property (nonatomic, strong) UILabel* textDate;

@property (nonatomic, strong) EZClickImage* authorIcon;

- (void) setTimeStr:(NSString*)timeStr;

- (void) setChatStr:(NSString*)chatStr name:(NSString*)name;

@end
