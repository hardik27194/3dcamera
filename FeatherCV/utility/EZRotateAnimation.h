//
//  EZRotateAnimation.h
//  FeatherCV
//
//  Created by xietian on 14-2-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAnimationUtil.h"

typedef enum{
    kAverageSpeed,
    kEasyInSpeed,
    kEasyOutSpeed
}EZRotationMode;

@interface EZRotateAnimation : NSObject<EZAnimInterface>

- (id) init:(UIView*)view interval:(CGFloat)interval rad:(CGFloat)rad repeat:(BOOL)repeat;

@property (nonatomic, assign) BOOL stopAnimation;

@property (nonatomic, assign) EZRotationMode rotationMode;

@property (nonatomic, assign) CGFloat currentSpeed;

@property (nonatomic, assign) CGFloat radTotal;

@property (nonatomic, strong) UIView* rotateView;

@property (nonatomic, assign) CGFloat interval;

@property (nonatomic, assign) CGFloat totalSteps;

@property (nonatomic, assign) double totalAngle;

@property (nonatomic, assign) CGFloat currentSteps;

@property (nonatomic, assign) double previousGress;

//If it is repeat, then the speed is always maintain at the highest speed
//Until it move done.
@property (nonatomic, assign) BOOL repeat;

@end
