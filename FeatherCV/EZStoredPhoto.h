//
//  EZStoredPhoto.h
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EZStoredPhoto : NSObject

//This is upload status, used to indicate if this image is used to replace the original or not.
@property (nonatomic, assign) BOOL isOriginal;

@property (nonatomic, assign) EZUploadStatus uploadStatus;

@property (nonatomic, strong) EZEventBlock successBlock;

@property (nonatomic, strong) EZEventBlock failBlock;

@property (nonatomic, strong) NSString* localFileURL;

//You can put it into status
@property (nonatomic, strong) NSString* remoteURL;

@property (nonatomic, assign) BOOL removed;

//Mean the url which will store the original URL.
@property (nonatomic, strong) NSString* originalURL;

//Can be used to adjust the sequence of the photos
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, strong) NSString* taskID;

@property (nonatomic, strong) NSString* photoID;

@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, strong) NSMutableArray* infos;

@property (nonatomic, assign) CGRect frontRegion;

- (void) populate:(NSDictionary*)dict;

- (NSDictionary*) toDict;

@end
