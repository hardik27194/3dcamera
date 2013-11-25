//
//  EZWeiboUtil.h
//  ShowHair
//
//  Created by xietian on 13-3-21.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

/**
#import <Foundation/Foundation.h>
#import "SinaWeibo.h"
#import "EZConstants.h"

//All the weibo related operation will be found here.
//Keep it simple and stupid
//Cool, let's do it
typedef enum {
    WeiboLoginFailure,//network or something else
    WeiboLoginCancel,
    WeiboLoginSuccess,
    WeiboUserInfoFailure,
    WeiboLogout
} WeiboLoginStatus;

@interface EZWeiboResult : NSObject

@property (nonatomic, strong) id resultObj;

@property (nonatomic, assign) BOOL result;

@end

#define WeiboUserInfoRequest @"users/show.json"



@interface EZWeiboUtil : NSObject<SinaWeiboDelegate, SinaWeiboRequestDelegate>

+ (EZWeiboUtil*) getInstance;

@property (nonatomic, strong) SinaWeibo* weibo;

@property (nonatomic, assign) WeiboLoginStatus loginStatus;

@property (nonatomic, assign) BOOL requestSuccess;

@property (nonatomic, strong) EZEventBlock callback;

@property (nonatomic, strong) NSError* requestError;

//Fetched back user info will be stored in this NSDictionary
@property (nonatomic, strong) NSDictionary* userInfo;

//Trigger the auth process. 
- (void) auth:(EZEventBlock)callback;


- (void) cleanWeiboStatus;


- (void) shareMessage:(NSString*)msg link:(NSString*)link image:(UIImage*)image callback:(EZEventBlock)callback;

- (BOOL) handleURL:(NSURL*)url;

- (void) setupAccessToken:(NSString*)accessToken userID:(NSString*)userID expirationDate:(NSDate*)expirationDate;

@end
**/
