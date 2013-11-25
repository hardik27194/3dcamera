//
//  EZWeixinUtil.m
//  ShowHair
//
//  Created by xietian on 13-3-23.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

/**
#import "EZWeixinUtil.h"
#import "WXApi.h"

@implementation EZWeixinUtil

+ (EZWeixinUtil*) getInstance
{
    static EZWeixinUtil* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZWeixinUtil alloc] init];
    });
    
    return instance;
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        EZDEBUG(@"Get request from WX:%@",req);
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        EZDEBUG(@"Seems I need to show some message. why?");
    }
    
}

-(void) onResp:(BaseResp*)resp
{
    _response = resp;
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        BOOL result = FALSE;
        if(resp.errCode == 0){
            result = TRUE;
        }
        if(_callback){
            _callback(@(result));
        }
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        //I can post a message from this place
        //Under what circumstance will get this result?
        //I don't know. 
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void) sendLinkedMessage:(NSString*)title content:(NSString*)content image:(UIImage*)image link:(NSString*)link scene:(NSInteger)scene callback:(EZEventBlock)callback
{
    
        EZDEBUG(@"title:%@, content:%@, link:%@, image:%@", title, content, link, image);
        _callback = callback;
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = content;
        [message setThumbImage:image];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = link;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];

}

@end
 
**/
