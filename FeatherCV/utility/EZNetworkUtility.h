//
//  EZNetworkUtility.h
//  SchoolCommunity
//
//  Created by xietian on 13-1-14.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZConstants.h"

@class EZDownloadHolder;
@interface EZNetworkUtility : NSObject

//This Method used to download large files from the network.
//The parameter for the EZOperationBlock is the temporary file name
//I will use a fixed file name for time being.
+ (void) download:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block;

+ (void) postJson:(NSString*)url parameters:(id)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block;



+ (void) getJson:(NSString*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block;

+ (void) getJson:(NSString*)url parameters:(id)params complete:(EZEventBlock)complete failblk:(EZEventBlock)block;

+ (void) upload:(NSString*)uploadURL parameters:(NSDictionary*)parameters fileURL:(NSString*)fileURL complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk progress:(EZProgressCheck)progress;

//The purpose of this method is to move the json combination out of the execution queue
+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue;

+ (void) getJson:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue;


+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method;

+ (void) getJson:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method;


//auto retry version
//Will retry countless times
//Maybe.
+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi;

+ (void) getJson:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi;

//The purpose of this class is to generate the url we need.
+ (NSString*) patch:(NSString*)str parameters:(NSArray*)parameters;

//Now don't support recursively fill object.
//Later we may support, it is full of fun.
+ (id) fillObject:(Class)class1 data:(NSDictionary*)dict fields:(NSArray*)arr;

+ (id) fillObjects:(Class)class1 data:(NSArray*)array type:(NSDictionary*)typeMap;

+ (void) fillObjectsAsync:(Class)class1 data:(NSArray*)array type:(NSDictionary*)typeMap complete:(EZEventBlock)block;

//This is a upgrade version, if the map have not value, I will assign the value directly.
+ (id) fillObject:(Class)class1 data:(NSDictionary *)dict type:(NSDictionary*)typeMap;

+ (id) object2Dict:(id)obj;

+ (NSArray*) arrToDict:(NSArray*)arr;


+ (NSString*) parseSessionID:(NSString*)sessionStr;

+ (void) storeSession:(NSString*)sessionID;

+ (NSString*) getCurrentSession;



- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi method:(NSString*)method;


- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi;
//Upload method for MG
//Have all the parameters I need
- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk;

- (void) upload:(NSString*)uploadURL file:(NSString*)videoFile uploadField:(NSString*)fieldName headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk method:(NSString*)method;

+ (void) downloadImage:(NSString*)fullURL downloader:(EZDownloadHolder*)holder;

+ (id) str2json:(NSString*)str;


+ (EZNetworkUtility*) getInstance;

+ (void) cleanCookie;

+ (NSString*) getSessionFromCookie;

//Set session cookie back
+ (void) setSessionCookie:(NSString*)sessionid;

@property (nonatomic, strong) NSString* sessionID;

@property (nonatomic, strong) NSMutableArray* pendingRequest;

@property (nonatomic, assign) BOOL isPauseRequest;

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

+ (void) postParameterFullURL:(NSString *)url parameters:(id)params complete:(EZEventBlock)completed failblk:(EZEventBlock)errorBlk isBackground:(BOOL)background;
//Will post the
+ (void) postParameterAsJson:(NSString*)url parameters:(id)params complete:(EZEventBlock)complete failblk:(EZEventBlock)block;

+ (void) postParameterAsJson:(NSString*)url parameters:(id)params complete:(EZEventBlock)complete failblk:(EZEventBlock)block isBackground:(BOOL)background;
/**
dispatch_queue_t backgroundQueue = dispatch_queue_create("com.name.bgqueue", NULL);
AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
operation.successCallbackQueue = backgroundQueue;
**/
@end
