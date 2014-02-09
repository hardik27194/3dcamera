//
//  EZNetworkUtility.m
//  SchoolCommunity
//
//  Created by xietian on 13-1-14.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZNetworkUtility.h"
#import "AFNetworking.h"
//#import "AFDownloadRequestOperation.h"
#import "EZConstants.h"
#import "EZThreadUtility.h"
//#import "ASIFormDataRequest.h"
#import "EZUploadHandler.h"
#import "EZExtender.h"
#import "EZReachability.h"
#import "EZMessageCenter.h"
#import "EZAppConstants.h"
#import "EZFeatherAPIClient.h"
#import "EZDataUtil.h"
#import <objc/runtime.h>


static EZNetworkUtility* instance;

@implementation EZNetworkUtility


- (id) init
{
    self = [super init];
    _pendingRequest = [[NSMutableArray alloc] init];
    return self;
}


//I will get the instance.
+ (id) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZNetworkUtility alloc] init];
    });
    
    return instance;
}

- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi method:(NSString*)method
{
    NetworkStatus ns = [EZReachability currentReachabiliy].currentReachabilityStatus;
    if(ns == ReachableViaWiFi || (ns == ReachableViaWWAN && !onlyWifi)){
        [[EZNetworkUtility getInstance] uploadImage:uploadURL file:videoFile parameters:parameters complete:completed error:!retry?errorBlk:^(id err){
            [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
                [[EZNetworkUtility getInstance] uploadImage:uploadURL file:videoFile parameters:parameters complete:completed error:errorBlk retry:retry onlyWifi:onlyWifi method:method];
            } once:YES];
        } method:method];
        
    }else{
        EZDEBUG(@"Registr reachability Event");
        [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
            [[EZNetworkUtility getInstance] uploadImage:uploadURL file:videoFile parameters:parameters complete:completed error:errorBlk retry:retry onlyWifi:onlyWifi method:method];
        } once:YES];
    }
}


- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi
{
    [self uploadImage:uploadURL file:videoFile parameters:parameters complete:completed error:errorBlk retry:retry onlyWifi:onlyWifi method:nil];
}

- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk method:(NSString*)method
{
    NSString* sessionid = [EZNetworkUtility getCurrentSession];
    EZDEBUG(@"sessionid:%@", sessionid);
    NSDictionary* headers = nil;
    if(sessionid){
        headers = @{@"Cookie":[NSString stringWithFormat: @"sessionid=%@", sessionid]};
    }
    [self upload:uploadURL file:videoFile uploadField:@"image" headers:headers parameters:parameters complete:completed error:errorBlk method:method];

}

- (void) uploadImage:(NSString*)uploadURL file:(NSString*)videoFile parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk
{
    NSString* sessionid = [EZNetworkUtility getCurrentSession];
    EZDEBUG(@"sessionid:%@", sessionid);
    NSDictionary* headers = nil;
    if(sessionid){
        headers = @{@"Cookie":[NSString stringWithFormat: @"sessionid=%@", sessionid]};
    }

    [self upload:uploadURL file:videoFile uploadField:@"image" headers:headers parameters:parameters complete:completed error:errorBlk method:nil];
}

- (void) upload:(NSString*)uploadURL file:(NSString*)videoFile uploadField:(NSString*)fieldName headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters  complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk method:(NSString*)method
{
    
    /**
    __weak EZNetworkUtility* weakSelf = self;
    ASIFormDataRequest* _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uploadURL]];
    
    if(method){
        [_request setRequestMethod:method];
    }
	
    //[_request addRequestHeader:@"Cookie" value:@"sessionid=7b86f3fca8c64f7ba50d780cf3785bf0"];
    ///NSData* data = [NSData dataWithContentsOfFile:videoFile];
    
    //EZDEBUG(@"file:%@, length:%i, header:%@, parameters:%@, fieldName:%@",videoFile,data.length,headers, parameters, fieldName);
    
    for(NSString* headerKey in headers){
        [_request addRequestHeader:headerKey value:[headers objectForKey:headerKey]];
    }
    
    EZUploadHandler* uploadHandler = [[EZUploadHandler alloc] init];
    [_pendingRequest addObject:uploadHandler];
    //For the sake to store the request reference so that it will not get released
    uploadHandler.request = _request;
    //[request setPostValue:@"test" forKey:@"value1"];
	//[request setPostValue:@"test" forKey:@"value2"];
    //NSString* finalName = [videoFile componentsSeparatedByString:@"/"].lastObject;
	//[_request setPostValue:finalName forKey:@"name"];
    EZDEBUG(@"upload parameters:%@", parameters);
    for(NSString* parameterKey in parameters.allKeys){
        [_request setPostValue:[parameters objectForKey:parameterKey] forKey:parameterKey];
    }
    
    
	[_request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[_request setShouldContinueWhenAppEntersBackground:YES];
#endif
	[_request setUploadProgressDelegate:uploadHandler];
	[_request setDelegate:uploadHandler];
	[_request setDidFailSelector:@selector(uploadFailed:)];
	[_request setDidFinishSelector:@selector(uploadFinished:)];
    __weak EZUploadHandler* weakHandler = uploadHandler;
	uploadHandler.uploadSuccess = ^(ASIHTTPRequest* request){
        EZDEBUG(@"request responseCode:%i, response detail:%@", request.responseStatusCode, request.responseString);
        if(completed){
            if(request.responseStatusCode < 300){
                completed(str2json(request.responseString));
            }else if(errorBlk){
                errorBlk(request.responseString);
            }
        }
        [weakSelf.pendingRequest removeObject:weakHandler];
    };
    uploadHandler.uploadFailure =  ^(ASIHTTPRequest* request){
        [weakSelf.pendingRequest removeObject:weakHandler];
        EZDEBUG(@"failed, response:%@, responseString:%@", request.responseHeaders, request.responseString);
        if(errorBlk){
            errorBlk(request);
        }
    };
    
    [_request setFile:videoFile forKey:fieldName];
	[_request startAsynchronous];
    EZDEBUG(@"Start uploading the video files");

    **/
}

+ (void) upload:(NSString *)uploadURL parameters:(NSDictionary *)parameters file:(NSString *)fullPath complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk progress:(EZProgressCheck)progress
{
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSArray* fileNames = [fullPath componentsSeparatedByString:@"/"];
    
    NSString* fileName = fileNames.count > 0?[fileNames objectAtIndex:fileNames.count - 1]:fullPath;
    // 2. Create an `NSMutableURLRequest`.
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:baseUploadURL
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileURL:[NSURL fileURLWithPath:fullPath] name:@"myfile" fileName:fileName mimeType:@"image/jpeg" error:nil];
                     }];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                         if(completed){
                                             completed(responseObject);
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         if(errorBlk){
                                             errorBlk(error);
                                         }
                                     }];
    
    // 4. Set the progress block of the operation.
    if(progress){
        [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        //NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
            progress((CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite);
        }];
    }
    // 5. Begin!
    [operation start];
}

- (void) uploadWorkable:(NSString *)uploadURL parameters:(NSDictionary *)parameters file:(NSString *)fullPath complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSDictionary *parameters = @{@"foo": @"bar"};
    NSURL *filePath = [NSURL fileURLWithPath:fullPath];
    [manager POST:baseUploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"myfile" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        EZDEBUG(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        EZDEBUG(@"Error: %@", error);
    }];
}

- (void) uploadTask:(NSString *)uploadURL parameters:(NSDictionary *)parameters file:(NSString *)fullPath complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:uploadURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    
    NSArray* fileNames = [fullPath componentsSeparatedByString:@"/"];
    
    NSString* fileName = fileNames.count > 0?[fileNames objectAtIndex:fileNames.count - 1]:fullPath;
    NSURL* fileURl = [NSURL fileURLWithPath:fullPath];
    EZDEBUG(@"The final extracted file name:%@, full file URL:%@", fileName, fileURl.absoluteString);

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:fileURl progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            EZDEBUG(@"Error info: %@", error);
            if(errorBlk){
                errorBlk(error);
            }
        } else {
            EZDEBUG(@"Success: %@ %@", response, responseObject);
            if(completed){
                completed(responseObject);
            }
        }
    }];
    [uploadTask resume];
}

//Once completed, I will start to play the video immediately.
//Now just print some information that I have completed.
- (void) uploadOld:(NSString*)uploadURL parameters:(NSDictionary *)parameters file:(NSString *)fullPath complete:(EZEventBlock)completed error:(EZEventBlock)errorBlk
{
    NSArray* fileNames = [fullPath componentsSeparatedByString:@"/"];
    
    NSString* fileName = fileNames.count > 0?[fileNames objectAtIndex:fileNames.count - 1]:fullPath;
    NSURL* fileURl = [NSURL fileURLWithPath:fullPath];
    EZDEBUG(@"The final extracted file name:%@, full file URL:%@", fileName, fileURl.absoluteString);
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURl name:@"myfile" fileName:fileName mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            EZDEBUG(@"Error: %@", error);
            if(errorBlk){
                errorBlk(error);
            }
        } else {
            EZDEBUG(@"%@ %@", response, responseObject);
            if(completed){
                completed(responseObject);
            }
        }
    }];
    
    [uploadTask resume];
        
}

/**
//By default all the things will downloaded to the cache directory.
+ (void) download:(NSURL *)url complete:(EZEventBlock)complete failblk:(EZEventBlock)failblk
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString* sessionid = [EZNetworkUtility getCurrentSession];
    EZDEBUG(@"sessionid:%@", sessionid);
    if(sessionid){
        //headers = @{@"Cookie":[NSString stringWithFormat: @"sessionid=%@", sessionid]};
        [request setAllHTTPHeaderFields:@{@"Cookie":[NSString stringWithFormat: @"sessionid=%@", sessionid]}];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:url.path];
    EZDEBUG(@"Will begin download");
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        EZDEBUG(@"Successfully downloaded file to %@", path);
        if(complete){
            complete(path);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        EZDEBUG(@"Error: %@", error);
        if(failblk){
            failblk(error);
        }
    }];
    [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
    }];
    //[operations addObject:operation];
    [[EZThreadUtility getInstance] executeOperation:operation];
}

 **/
//Simplify the function call. 
+ (id) str2json:(NSString*)str
{
    EZDEBUG("before json:%@", str);
    if(str == nil){
        return nil;
    }
    NSError* error = nil;
    id res = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers  error:&error];
    if(error){
        EZDEBUG(@"Error:%@", error);
        return nil;
    }
    return res;
}

+ (NSString*) parseSessionID:(NSString*)sessionStr
{
    EZDEBUG(@"start parsing sessionid");
    if(!sessionStr){
        return nil;
    }
    NSRange range = [sessionStr rangeOfString:@"sessionid="];
    if(range.length > 0){
        NSInteger pos = range.location + range.length;
        NSRange endPos = [sessionStr rangeOfString:@";"];
        if(endPos.location > pos){
            NSString* sessionid = [sessionStr substringWithRange:NSMakeRange(pos, endPos.location-pos)];
            EZDEBUG(@"final session is:%@", sessionid);
            return sessionid;
        }
    }
    return nil;
}

+ (void) storeSession:(NSString*)session
{
    [[NSUserDefaults standardUserDefaults] setValue:session forKey:EZCurrentSessionID];
}

+ (NSString*) getCurrentSession
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:EZCurrentSessionID];
}


+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue
{
    [self postJson:url action:action parameters:dicts complete:complete failblk:block callbackQueue:callbackQueue method:nil];
}

//Keey retry until success.
//Simplest and brutal.
//It is meaningless to pass limit when there is no 
+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi
{
    NetworkStatus ns = [EZReachability currentReachabiliy].currentReachabilityStatus;
    if(ns == ReachableViaWiFi || (ns == ReachableViaWWAN && !onlyWifi)){
        [EZNetworkUtility postJson:url action:action parameters:dicts complete:complete
                           failblk:!retry?block:^(id sender){
                               EZDEBUG(@"retry get called, error:%@", sender);
                               [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
                                   [EZNetworkUtility postJson:url action:action parameters:dicts complete:complete failblk:block callbackQueue:callbackQueue method:method retry:retry onlyWifi:onlyWifi];
                               } once:YES];
                           } callbackQueue:callbackQueue method:method];
    }else{
        EZDEBUG(@"Registr reachability Event");
        [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
            [EZNetworkUtility postJson:url action:action parameters:dicts complete:complete failblk:block callbackQueue:callbackQueue method:method retry:retry onlyWifi:onlyWifi];
        } once:YES];
    }
    
}

+ (void) getJson:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString*)method retry:(BOOL)retry onlyWifi:(BOOL)onlyWifi
{
    NetworkStatus ns = [EZReachability currentReachabiliy].currentReachabilityStatus;
    if(ns == ReachableViaWiFi || (ns == ReachableViaWWAN && !onlyWifi)){
        [EZNetworkUtility getJson:url complete:complete
                           failblk:!retry?block:^(id sender){
                               EZDEBUG(@"retry get called, error:%@", sender);
                               [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
                                   [EZNetworkUtility getJson:url complete:complete failblk:block callbackQueue:callbackQueue method:method retry:retry onlyWifi:onlyWifi];
                               } once:YES];
                           } callbackQueue:callbackQueue method:method];
    }else{
        EZDEBUG(@"Registr the reablility event");
        [[EZMessageCenter getInstance] registerEvent:EZReachabilityEvent block:^(id sender){
            [EZNetworkUtility getJson:url complete:complete failblk:block callbackQueue:callbackQueue method:method retry:retry onlyWifi:onlyWifi];
        } once:YES];
    }

}


+ (void) storeBackedCookie:(NSDictionary*)headers
{
    NSString* cookie = [headers objectForKey:@"Set-Cookie"];
    EZDEBUG(@"Cookie is:%@, allHeaderFields:%@",cookie,headers);
    NSString* sessionID = [self parseSessionID:cookie];
    if(sessionID){
        [self storeSession:sessionID];
    }
}

+ (void) postJson:(NSURL*)url action:(NSString*)action parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString *)method
{
    /**
     if(session){
     [client setDefaultHeader:@"Cookie" value:[NSString stringWithFormat:@"sessionid=%@; Path=/", session]];
     }
     **/
    /**
    
    AFHTTPClient* client = [AFHTTPClient clientWithBaseURL:url];
    NSString* session = [EZNetworkUtility getSessionFromCookie];
    EZDEBUG(@"post url:%@, sessionid:%@, %@", url, session, dicts);
    
   
    [client postPath:action parameters:dicts success:^(AFHTTPRequestOperation* ops, id responseObject){
        EZDEBUG(@"ResponseObject:%@, response string:%@", [responseObject class], ops.responseString);
        id json = [EZNetworkUtility str2json:ops.responseString];
        if(complete){
            complete(json);
        }
        
    } failure:^(AFHTTPRequestOperation* ops, NSError* error){
        EZDEBUG(@"encounter error:%@", error);
        id json = nil;
        if(ops.responseString){
            json = [EZNetworkUtility str2json:ops.responseString];
        }
        if(block){
            block(json?json:error);
        }
    } callbackQueue:callbackQueue method:method];
    **/
    
}

+ (void) getJson:(NSURL *)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue
{
    [self getJson:url complete:complete failblk:block callbackQueue:callbackQueue method:nil];
}


+ (void) setSession:(NSMutableURLRequest*)request
{
    NSString* session = [EZNetworkUtility getCurrentSession];
    EZDEBUG(@"sessionid:%@", session);
    if(session){
        [request setValue:[NSString stringWithFormat:@"sessionid=%@; Path=/", session] forHTTPHeaderField:@"Cookie"];
    }
}
+ (void) getJson:(NSURL*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block callbackQueue:(dispatch_queue_t)callbackQueue method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    /**
    if(method){
        [request setHTTPMethod:method];
    }
    
    NSString* sessionid = [self getSessionFromCookie];
    EZDEBUG(@"get %@, sessionid:%@", url, sessionid);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"App.net Global Stream: %@", JSON);
        //NSString* result = [JSON objectForKey:@"result"];
        //if([@"success" isEqualToString:result]){
            EZDEBUG(@"success, raw response:%@", JSON
                    );
            if(complete){
                complete(JSON);
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         
        if(block){
            block(JSON?JSON:error);
        }
        
    } callbackQueue:callbackQueue];
    [operation start];
     **/
}

+ (void) getJsonTest:(NSString *)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@", baseServiceURL, url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        EZDEBUG(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        EZDEBUG(@"Error: %@", error);
    }];
}

//Use another method.
+ (void) getJson:(NSString*)url complete:(EZEventBlock)complete failblk:(EZEventBlock)block
{
    //[self getJson:url complete:complete failblk:block callbackQueue:nil];
    [[EZFeatherAPIClient sharedClient].requestSerializer setValue:[EZDataUtil getInstance].currentPersonID forHTTPHeaderField:EZSessionHeader];
    EZDEBUG(@"The absolute url is:%@", url);
    [[EZFeatherAPIClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        if (complete) {
            complete(JSON);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(error);
        }
    }];

}


+ (void) postJson:(NSString*)url parameters:(NSDictionary*)dicts complete:(EZEventBlock)complete failblk:(EZEventBlock)block
{
    [[EZFeatherAPIClient sharedClient].requestSerializer setValue:[EZDataUtil getInstance].currentPersonID forHTTPHeaderField:EZSessionHeader];
    [[EZFeatherAPIClient sharedClient] POST:url parameters:dicts success:^(NSURLSessionDataTask * __unused task, id JSON) {
        if (complete) {
            complete(JSON);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}


+ (void) postParameterAsJson:(NSString *)url parameters:(id)params complete:(EZEventBlock)completed failblk:(EZEventBlock)errorBlk
{
    //NSMutableURLRequest* request =
    
    AFJSONRequestSerializer* serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:[EZDataUtil getInstance].currentPersonID forHTTPHeaderField:EZSessionHeader];
    NSMutableURLRequest* request = [serializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", baseServiceURL, url] parameters:params error:nil];
    
    //[[EZFeatherAPIClient sharedClient] ]
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];

    
    //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                         if(completed){
                                             completed(responseObject);
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         if(errorBlk){
                                             errorBlk(error);
                                         }
                                     }];
    [operation start];
}


+ (id) fillObject:(Class)class1 data:(NSDictionary*)dict fields:(NSArray*)arr
{
    id res = [[class1 alloc] init];
    
    for(NSString* field in arr){
        [res setValue:[dict objectForKey:field] forKey:field];
    }
    return res;
}


+ (NSString*) patch:(NSString*)str parameters:(NSArray*)parameters
{
    if([str hasSuffix:@"/"]){
        str = [str substringToIndex:str.length-1];
    }
    NSMutableString* res = [[NSMutableString alloc] initWithString:str];
    for(NSObject* obj in parameters){
        [res appendFormat:@"/%@", obj];
    }
    return  res;
}

+ (id) fillObjects:(Class)class1 data:(NSArray*)array type:(NSDictionary*)typeMap
{
    //EZDEBUG(@"FillObjects:%@", typeMap);
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:array.count];
    for(NSDictionary* dict in array){
        if([dict isKindOfClass:[NSDictionary class]]){
            [res addObject:[EZNetworkUtility fillObject:class1 data:dict type:typeMap]];
        }
    }
    return res;
}

//Have 2 more extra switch.
//Which smell bad.
//How to address this?
//Setup the completion block thread.
//Then only need to swich once. is enough.
//Just to verify if the slow response really caused by the object serialization?
+ (void) fillObjectsAsync:(Class)class1 data:(NSArray*)array type:(NSDictionary*)typeMap complete:(EZEventBlock)block
{
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        NSArray* objs = [self fillObjects:class1 data:array type:typeMap];
        if(block){
            dispatch_async(dispatch_get_main_queue(), ^(){
                block(objs);
            });
        }
    } isConcurrent:YES];
}

+ (BOOL) isPrimeClass:(Class)cls
{
    if([cls isSubclassOfClass:[NSNumber class]] || [cls isSubclassOfClass:[NSString class]]){
        return true;
    }
    return false;
}
//Too complicated, let's test our assumption.
+ (NSArray*) arrToDict:(NSArray*)arr
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for(id val in arr){
        if([EZNetworkUtility isPrimeClass:[val class]]){
            EZDEBUG(@"prime Type:%@", val);
            [res addObject:val];
        }else if([[val class] isSubclassOfClass:[NSArray class]]){
            EZDEBUG(@"arr type:%@", val);
            [res addObject:[EZNetworkUtility arrToDict:val]];
        }else if([[val class] isSubclassOfClass:[NSDictionary class]]){
            [res addObject:val];
        }else{
            EZDEBUG(@"complicated type:%@", val);
            [res addObject:[EZNetworkUtility object2Dict:val]];
        }
    }
    return res;
}


+ (id) object2Dict:(id)obj
{
    unsigned int intVal = 0;
    Class class1 = [obj class];
    if([EZNetworkUtility isPrimeClass:class1]){
        return obj;
    }
    objc_property_t* properties = class_copyPropertyList(class1, &intVal);
    //sid res = [[class alloc] init];
    //EZDEBUG(@"Property count %i", intVal);
    NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
    for(int i =0; i < intVal; i++){
        NSString* propName = char2String(property_getName(properties[i]));
        NSString* attribute = char2String(property_getAttributes(properties[i]));
        //EZDEBUG(@"propName:%@, attributes:%@", propName, attribute);
        id value = [obj valueForKey:propName];
        if(value){
            //NSString* typeName = [[attribute componentsSeparatedByString:@","] objectAtIndex:0];
            //Class valueType = [value class];
            //Class vtype = [EZNetworkUtility retIfNotMetaClass:typeName];
            if([EZNetworkUtility isPrimeClass:[value class]]){
                //EZDEBUG(@"Set dirctly for propName:%@", propName);
                [res setValue:value forKey:propName];
            }else if([[value class] isSubclassOfClass:[NSArray class]]){
                //EZDEBUG(@"set Array for:%@",propName);
                [res setValue:[EZNetworkUtility arrToDict:value] forKey:propName];
            }else{
                //EZDEBUG(@"fill again for name:%@", propName);
                [res setValue:[EZNetworkUtility object2Dict:value] forKey:propName];
            }
        }else{
            //EZDEBUG(@"%@ is nil", propName);
        }
    }
    return res;
}

+ (id) fillObject:(Class)class1 data:(NSDictionary *)dict type:(NSDictionary*)typeMap
{
    unsigned int intVal = 0;
    objc_property_t* properties = class_copyPropertyList(class1, &intVal);
    id res = [[class1 alloc] init];
    //EZDEBUG(@"Property count %i", intVal);
    for(int i =0; i < intVal; i++){
        NSString* propName = char2String(property_getName(properties[i]));
        NSString* attribute = char2String(property_getAttributes(properties[i]));
        //EZDEBUG(@"propName:%@, attributes:%@", propName, attribute);
        NSString* typeKey = [NSString stringWithFormat:@"%@.%@",class1,propName];
        
        Class typeName =[typeMap objectForKey:typeKey];
        
        //EZDEBUG(@"typeKey:%@, typeName:%@", typeKey, typeName);
        
        id value = [dict objectForKey:propName];
        if(typeName){
            if([[value class] isSubclassOfClass:[NSDictionary class]]){
                [res setValue:[EZNetworkUtility fillObject:typeName data:value type:typeMap] forKey:propName];
            }else if([[value class] isSubclassOfClass:[NSArray class]]){
                NSArray* curValues = (NSArray*)value;
                NSMutableArray* arrs = [[NSMutableArray alloc] initWithCapacity:curValues.count];
                for(NSDictionary* val in curValues){
                    [arrs addObject:[EZNetworkUtility fillObject:typeName data:val type:typeMap]];
                }
                [res setValue:arrs forKey:propName];
                
            }
            else{//What's the meaning of this, think about it later
                //[res setValue:value forKey:propName];
                EZDEBUG(@"Unexpected value for type, ignore it:%@", propName);
                [res setValue:nil forKey:propName];
            }
        }else if(value){
            NSString* typeName = [[attribute componentsSeparatedByString:@","] objectAtIndex:0];
            Class vtype = [EZNetworkUtility retIfNotMetaClass:typeName];
            if(!vtype){
                //EZDEBUG(@"Set dirctly for type:%@, propName:%@", vtype, propName);
                if([[value class] isSubclassOfClass:[NSNull class]]){
                    //Do nothing for NSNUll.
                }else{
                    [res setValue:value forKey:propName];
                }
            }else if([vtype isSubclassOfClass:[NSDate class]]){
                EZDEBUG(@"is Date:%@", value);
                //Old formatter. 
                //NSDate* dt = [NSDate stringToDate:@"yyyy-MM-dd HH:mm:ss" dateString:value];
                //"2013-03-05T15:28:10+00:00"
                if(value && [[value class] isSubclassOfClass:[NSString class]]){
                    NSString* stripped = [[value componentsSeparatedByString:@"+"] objectAtIndex:0];
                    NSDate* dt = [NSDate stringToDate:EZJsonDateFormatter dateString:stripped];
                    EZDEBUG("date type:%@, propName:%@, converted date:%@", stripped, propName, dt);
                    [res setValue:dt forKey:propName];
                }
            }
            else{
                //EZDEBUG(@"fill again for name:%@, type:%@", propName, vtype);
                [res setValue:[EZNetworkUtility fillObject:vtype data:value type:typeMap] forKey:propName];
            }
        }
                          
    }
    return res;
}

+ (BOOL) isMetaClass:(NSString*)className
{
    if([className rangeOfString:@"@"].length > 0){
        NSString* classOnly = [className substringFromIndex:2];
        //EZDEBUG(@"type:%@", classOnly);
        if([classOnly isEqualToString:@"NSArray"] || [classOnly isEqualToString:@"NSMutableArray"]
           || [classOnly isEqualToString:@"NSDictionary"] || [classOnly isEqualToString:@"NSMutableDictionary"] || [classOnly isEqualToString:@"NSString"] ||[classOnly isEqualToString:@"NSMutableString"]
           ){
            return YES;
        }
        return NO;
    }else{
        return YES;
    }
}

+ (void) upload:(NSURL *)file uploadURL:(NSString *)baseURL file:(NSString*)fullName uploadPath:(NSString*)path success:(EZEventBlock)blk failBlk:(EZEventBlock)failBlk
{
    /**
   AFHTTPClient* httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:baseURL]];
    NSString* uploadedFile = [fullName componentsSeparatedByString:@"/"].lastObject;
    NSData* data = [NSData dataWithContentsOfFile:fullName];
    EZDEBUG(@"File name:%@ size:%i",uploadedFile, data.length);
    NSMutableURLRequest *afRequest = [httpClient multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:data name:@"file" fileName:uploadedFile mimeType:@"video/quicktime"];
                                      }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
         
     }];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {NSLog(@"Success");}
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {NSLog(@"error: %@",  operation.responseString);}];
    [operation start];
     **/
}

+ (Class) retIfNotMetaClass:(NSString*)className
{
    if([className rangeOfString:@"@"].length > 0){
        NSString* classOnly = [className substringWithRange:NSMakeRange(3, className.length-4)];
        //EZDEBUG(@"type:%@", classOnly);
        if([classOnly isEqualToString:@"NSArray"] || [classOnly isEqualToString:@"NSMutableArray"]
           || [classOnly isEqualToString:@"NSDictionary"] || [classOnly isEqualToString:@"NSMutableDictionary"] || [classOnly isEqualToString:@"NSString"] ||[classOnly isEqualToString:@"NSMutableString"]
           ){
            return nil;
        }
        return NSClassFromString(classOnly);
    }else{
        return nil;
    }
}

+ (void) cleanCookie
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:str2url(serverHostURL)];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+ (void) setSessionCookie:(NSString*)sessionid
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"sessionid" forKey:NSHTTPCookieName];
    [cookieProperties setObject:sessionid forKey:NSHTTPCookieValue];
    [cookieProperties setObject:serverHost forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:serverHost forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

+ (NSString*) getSessionFromCookie
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: str2url(serverHostURL)];
    for (NSHTTPCookie *cookie in cookies)
    {
        EZDEBUG(@"name:%@:%@", cookie.name, cookie.value);
        if([@"sessionid" isEqualToString:cookie.name]){
            return cookie.value;
        }
       // [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    return nil;

}

@end
