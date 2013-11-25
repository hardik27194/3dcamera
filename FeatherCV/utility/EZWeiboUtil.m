//
//  EZWeiboUtil.m
//  ShowHair
//
//  Created by xietian on 13-3-21.
//  Copyright (c) 2013年 xietian. All rights reserved.
//
/**
#import "EZWeiboUtil.h"
#import "EZMessageCenter.h"
#import "EZExtender.h"

static EZWeiboUtil* instance;



@implementation EZWeiboResult

@end

@implementation EZWeiboUtil

+ (EZWeiboUtil*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZWeiboUtil alloc] init];
    });
    return instance;
}

- (id) init
{
    self = [super init];
    _weibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self];
    return self;
}


- (void) auth:(EZEventBlock)callback
{
    [[EZMessageCenter getInstance] registerEvent:WeiboLoginEvent block:callback once:YES];
    [_weibo logIn];
}

- (void) cleanWeiboStatus
{
    _weibo.accessToken = nil;
    _weibo.userID = nil;
}


- (void) shareMessage:(NSString *)msg link:(NSString *)link image:(UIImage *)image callback:(EZEventBlock)callback
{
    if(_weibo.accessToken.isNotEmpty){
        NSString* statusText = [NSString stringWithFormat:@"%@ %@", msg, link];
        _callback = callback;
        [_weibo requestWithURL:@"statuses/upload.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               statusText, @"status",
                               image, @"pic", nil]
                   httpMethod:@"POST"
                     delegate:self];
    }else{
        //Don't have accessToken yet, let's auth again
        EZDEBUG(@"Auth to weibo");
        [self auth:^(EZWeiboUtil* weiboUtil){
            if(weiboUtil.loginStatus == WeiboLoginSuccess){
                [weiboUtil shareMessage:msg link:link image:image callback:callback];
            }else{
                EZDEBUG(@"Failed to login to weibo:%@", weiboUtil.requestError);
            }
        }];
    }
}


- (void) setupAccessToken:(NSString*)accessToken userID:(NSString*)userID expirationDate:(NSDate*)expirationDate
{
    _weibo.accessToken = accessToken;
    _weibo.userID = userID;
    _weibo.expirationDate = expirationDate;
}

- (BOOL) handleURL:(NSURL*)url
{
   return [_weibo handleOpenURL:url];
}

//Delegate method for weibo
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    EZDEBUG(@"Login success sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", _weibo.userID, _weibo.accessToken,_weibo.expirationDate,_weibo.refreshToken);
    //I will bind the Weibo Auth information with current user
    //[[EZUserUtil getInstance] setCurrentUser:user];
    _loginStatus = WeiboLoginSuccess;
    [_weibo requestWithURL:WeiboUserInfoRequest
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    _loginStatus = WeiboLogout;
    [[EZMessageCenter getInstance] postEvent:WeiboLogoutEvent attached:self direct:YES];
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    _loginStatus = WeiboLoginCancel;
    [[EZMessageCenter getInstance] postEvent:WeiboLoginEvent attached:self direct:YES];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    _loginStatus = WeiboLoginFailure;
    [[EZMessageCenter getInstance] postEvent:WeiboLoginEvent attached:self direct:YES];
}

//when would this happen
//Let's check what they are doing in the demo code
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    _loginStatus = WeiboLoginFailure;
    EZDEBUG(@"accessToken fetch failure:%@", error);
    //Treat this as login failure
    [[EZMessageCenter getInstance] postEvent:WeiboLoginEvent attached:self direct:YES];
}


- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    _requestError = error;
    if([request.url hasSuffix:WeiboUserInfoRequest]){
        _loginStatus = WeiboUserInfoFailure;
        EZDEBUG(@"request failure");
       
        [[EZMessageCenter getInstance] postEvent:WeiboLoginEvent attached:self direct:YES];
    }else if([request.url hasSuffix:@"statuses/upload.json"]){
        if(_callback){
            _callback(@(FALSE));
        }
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if([request.url hasSuffix:WeiboUserInfoRequest]){
        _userInfo = result;
        EZDEBUG(@"Returned result:%@", result);
        [[EZMessageCenter getInstance] postEvent:WeiboLoginEvent attached:self direct:YES];
    }else if([request.url hasSuffix:@"statuses/upload.json"]){
        if(_callback){
            _callback(@(TRUE));
        }
    }
}


@end
**/