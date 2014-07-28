//
//  EZCustomButton.h
//  BabyCare
//
//  Created by xietian on 14-7-28.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZCustomButton : UIButton

- (id) initWithFrame:(CGRect)frame image:(UIImage*)image touchEffects:(BOOL)touchEffect;

@property (nonatomic, strong) EZEventBlock clicked;

@property (nonatomic, assign) BOOL touchEffects;

+ (EZCustomButton*) createButton:(CGRect)frame image:(UIImage*)image;

@end
