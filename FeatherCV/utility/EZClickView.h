//
//  EZClickView.h
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"

@interface EZClickView : UIView

@property (nonatomic, strong) EZEventBlock pressedBlock;

@property (nonatomic, strong) EZEventBlock releasedBlock;

@property (nonatomic, assign) BOOL enableTouchEffects;

@property (nonatomic, strong) UIColor* pressedColor;

@property (nonatomic, strong) UIView* pressedView;

@end
