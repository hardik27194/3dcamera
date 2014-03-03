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

- (void) animateButton:(CGFloat)duration lineWidth:(CGFloat)lineWidth completed:(EZEventBlock)completed;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGFloat targetLineWidth;

@property (nonatomic, assign) CGFloat srcLineWidth;

@property (nonatomic, strong) UIColor* cycleColor;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) EZAnimStatus animStatus;

@property (nonatomic, weak) CAShapeLayer* shapeLayer;

@property (nonatomic, assign) CGFloat totalCount;

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) BOOL stopAnimating;

@property (nonatomic, assign) CGFloat srcRadius;

@property (nonatomic, assign) EZEventBlock completed;

@end
