//
//  EZMotionRecorder.h
//  FeatherCV
//
//  Created by xietian on 14-5-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 What's the purpose of this class?
 It will keep track of motion and keep track of relative motion.
 It will generate the motion Image, which can play the image based on the relative movement
 of the phone.
 You just call the start, then feed then image.
 Then generate the MotionImage.
 MotionImage will have cover image.
 **/

@class EZMotionData;
@interface EZMotionRecorder : NSObject

@property (nonatomic, strong) NSMutableArray* storedMotionImages;

@property (nonatomic, strong) EZMotionData* startMotion;

@property (nonatomic, strong) EZMotionData* currentMotion;

- (void) start;

- (void) stop;

- (void) addImage:(UIImage*)image;

- (NSArray*) getSortedImages;

@end
