//
//  EZUploadHandler.m
//  SchoolCommunity
//
//  Created by xietian on 13-1-22.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZUploadHandler.h"

@implementation EZUploadHandler

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
    if(_uploadFailure){
        _uploadFailure(theRequest);
    }
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    if(_uploadSuccess){
        _uploadSuccess(theRequest);
    }
    
}

//I suspect this object get released too.
- (void) dealloc
{
    EZDEBUG(@"dealloc UploadHandler");
}

@end
