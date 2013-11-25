//
//  EZWeixinUtil.h
//  ShowHair
//
//  Created by xietian on 13-3-23.
//  Copyright (c) 2013年 xietian. All rights reserved.
//
/**
#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "EZConstants.h"

@interface EZWeixinUtil : NSObject<WXApiDelegate>

+ (EZWeixinUtil*) getInstance;

//Will back, the result will be in the callback method.
//Detail can be  found in the Util.
@property (nonatomic, strong) EZEventBlock callback;

@property (nonatomic, strong) BaseResp* response;

- (void) sendLinkedMessage:(NSString*)title content:(NSString*)content image:(UIImage*)image link:(NSString*)link scene:(NSInteger)scene callback:(EZEventBlock)callback;

@end
**/