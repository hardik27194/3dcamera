//
//  EZRotateAnimation.m
//  FeatherCV
//
//  Created by xietian on 14-2-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRotateAnimation.h"

@implementation EZRotateAnimation

- (id) init:(UIView*)view interval:(CGFloat)interval rad:(CGFloat)rad repeat:(BOOL)repeat
{
    self = [super init];
    _interval = interval;
    _totalSteps = interval * 60;
    _repeat = repeat;
    _totalAngle = M_PI * 2.0 * rad;
    _previousGress = 0.0;
    return self;
}

- (double) easyFunction:(double)stage
{
    return (3 - 2*stage)*stage*stage;
}

//Yes mean stop.
- (BOOL) animate
{
    if(_stopAnimation){
        return YES;
    }
    ++_currentSteps;
    double currentRatio = _currentSteps/_totalSteps;
    double progress = [self easyFunction:currentRatio];
    double delta = progress - _previousGress;
    if(_repeat && currentRatio > 0.5){
        --_currentSteps;
    }else{
        _previousGress = progress;
    }
    double deltaAngle = delta * _totalAngle;
    CATransform3D trans = CATransform3DRotate(_rotateView.layer.transform, -deltaAngle, 0.0, 1.0, 0.0);
    _rotateView.layer.transform = trans;
    return currentRatio >= 1.0;
}

@end
