//
//  EZShotTask.h
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalTasks;
@interface EZShotTask : NSObject

@property (nonatomic, assign) EZUploadStatus uploadStatus;

@property (nonatomic, strong) EZEventBlock successBlock;

@property (nonatomic, strong) EZEventBlock failBlock;

@property (nonatomic, strong) NSMutableArray* photos;

//When those photo get shot.
@property (nonatomic, strong) NSDate* shotDate;

//User can share this URL out
@property (nonatomic, strong) NSString* generatedURL;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* taskID;

@property (nonatomic, strong) NSString* personID;

@property (nonatomic, strong) LocalTasks* localTask;

@property (nonatomic, assign) BOOL uploading;

@property (nonatomic, assign) BOOL newlyUpload;

@property (nonatomic, assign) BOOL removed;

//If it is private, I will not show on the platform.
@property (nonatomic, assign) BOOL isPrivate;

//If it is true mean I want to upload the task too.
//Otherwise mean upload photo.
@property (nonatomic, assign) BOOL uploadTask;

- (void) populateTask:(NSDictionary*) dict;

- (NSDictionary*) toDict;

- (void) deleteLocal;

- (void) store;

@end
