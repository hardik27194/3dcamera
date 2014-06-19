//
//  EZClickView.h
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"


typedef enum {
    kPressColorChange,
    kPressEnlargeCycle,
    kPressGlow
} EZPressAnimType;

@interface EZClickView : UIView

@property (nonatomic, assign) EZPressAnimType animType;

@property (nonatomic, assign) CGFloat enlargeScale;

@property (nonatomic, strong) EZEventBlock pressedBlock;

@property (nonatomic, strong) EZEventBlock releasedBlock;

@property (nonatomic, strong) EZEventBlock longPressBlock;

@property (nonatomic, assign) CGFloat longPressTime;

//Which is a cooperation of different event.
@property (nonatomic, assign) BOOL longPressedCalled;

@property (nonatomic, assign) BOOL fingerPressed;

@property (nonatomic, assign) BOOL enableTouchEffects;

@property (nonatomic, strong) UIColor* pressedColor;

@property (nonatomic, strong) UIView* pressedView;

@property (nonatomic, assign) CGFloat orgWidth;

@property (nonatomic, assign) CGFloat orgHeight;

- (void) recieveLongPress:(CGFloat)time callback:(EZEventBlock)block;

- (void) pressed;

- (void) unpressed;

- (void) hideColor;


- (void) changeColor;

@end
