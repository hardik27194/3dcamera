//
//  EZStoredPhoto.h
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZStoredPhoto : NSObject

@property (nonatomic, strong) NSString* localFileName;

//You can put it into status
@property (nonatomic, strong) NSString* remoteURL;

//Can be used to adjust the sequence of the photos
@property (nonatomic, assign) NSInteger priority;

@property (nonatomic, assign) BOOL uploadStatus;

@end
