//
//  EZPopupView.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZPopupView : UIView

@property (nonatomic, strong) EZEventBlock saveBlock;

@property (nonatomic, strong) UILabel* title;

- (void) showInView:(UIView*)parentView animated:(BOOL)animated;

- (void) dismiss:(BOOL)animted;

@end
