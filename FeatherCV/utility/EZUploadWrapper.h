//
//  EZUploadWrapper.h
//  3DCamera
//
//  Created by xietian on 14-9-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZUploadWrapper : NSObject

@property (nonatomic, strong) id uploadObj;

@property (nonatomic, assign) EZUploadStatus status;

@property (nonatomic, strong) EZEventBlock successBlock;

@property (nonatomic, strong) EZEventBlock failBlock;

@end
