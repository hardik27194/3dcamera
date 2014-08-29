//
//  EZInfoDotView.h
//  3DCamera
//
//  Created by xietian on 14-8-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZInfoDotView : UIView

@property (nonatomic, strong) UIView* dotView;

- (id) initWithFrame:(CGRect)frame dotDiameter:(CGFloat)diameter color:(UIColor*)color;

@property (nonatomic, assign) BOOL movingState;

@property (nonatomic, assign) BOOL pressed;

@property (nonatomic, assign) CGPoint startPoint;

//In percent scale.
@property (nonatomic, assign) CGPoint finalPosition;

@property (nonatomic, strong) EZEventBlock moveCompleted;

@property (nonatomic, strong) EZEventBlock clicked;

+ (EZInfoDotView*) create:(CGPoint)point;

@end
