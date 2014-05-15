//
//  EZMotionImage.h
//  FeatherCV
//
//  Created by xietian on 14-5-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZMotionData;
@interface EZMotionImage : NSObject

@property (nonatomic, strong) UIImageView* container;

//Image have the relative motion and related images
@property (nonatomic, strong) NSArray* motionImages;

@property (nonatomic, strong) EZMotionData* startData;

//Start to play with the photo
- (void) play;

//Will unregister from the motionUtility.
//I can test it. see what's going on.
- (void) stop;


@end
