//
//  EZPhotoInfo.h
//  3DCamera
//
//  Created by xietian on 14-8-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZPhotoInfo : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSString* photoID;
@property (nonatomic, strong) NSString* infoID;

- (void) populate:(NSDictionary*)dict;

- (NSDictionary*) toDict;


@end
