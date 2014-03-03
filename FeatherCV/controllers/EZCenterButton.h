//
//  EZCenterButton.h
//  FeatherCV
//
//  Created by xietian on 14-3-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kAnimateInit,
    kAnimateStart,
    kAnimateMiddle,
    kAnimateSecond,
    kAnimateFinal
}EZAnimStatus;

@interface EZCenterButton : EZClickView

- (id)initWithFrame:(CGRect)frame cycleRadius:(CGFloat)radius lineWidth:(CGFloat)width;

- (void) changeLineAnimation;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) UIColor* cycleColor;

@property (nonatomic, assign) EZAnimStatus animStatus;

@property (nonatomic, weak) CAShapeLayer* shapeLayer;

@end
