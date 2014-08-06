//
//  EZShotTask.h
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZShotTask : NSObject

@property (nonatomic, strong) NSMutableArray* photos;

//When those photo get shot.
@property (nonatomic, strong) NSDate* shotDate;

//User can share this URL out
@property (nonatomic, strong) NSString* generatedURL;

@property (nonatomic, strong) NSString* name;

@end
