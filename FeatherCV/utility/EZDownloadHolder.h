//
//  EZDownloadHolder.h
//  FeatherCV
//
//  Created by xietian on 14-3-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZDownloadHolder : NSObject

@property (nonatomic, strong) NSMutableArray* success;

@property (nonatomic, strong) NSMutableArray* failures;

//URL or files? I guess URL is better.
@property (nonatomic, strong) NSString* downloaded;

@property (nonatomic, strong) NSString* filename;

@property (nonatomic, assign) BOOL isDownloading;

@property (nonatomic, strong) AFHTTPRequestOperation* requestOperation;
//_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
//_imageRequestOperation.responseSerializer = self.imageResponseSerializer;

- (void) insertSuccess:(EZEventBlock)block;

- (void) insertFailure:(EZEventBlock)block;

- (void) callSuccess;

- (void) callFailure:(id)failure;

@end
