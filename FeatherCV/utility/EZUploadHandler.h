//
//  EZUploadHandler.h
//  SchoolCommunity
//
//  Created by xietian on 13-1-22.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZConstants.h"

@class ASIHTTPRequest;
//The existence of this object is to make sure the upload of the ASI network could work properly.
//So what we are doing?
//
@interface EZUploadHandler : NSObject

- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;


@property (nonatomic, strong) EZEventBlock uploadFailure;
@property (nonatomic, strong) EZEventBlock uploadSuccess;
@property (nonatomic, strong) id request;

@end
