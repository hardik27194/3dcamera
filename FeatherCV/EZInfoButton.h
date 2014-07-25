//
//  EZInfoButton.h
//  FeatherCV
//
//  Created by xietian on 14-7-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZInfoButton : UIButton

@property (nonatomic, strong) UILabel* infoCount;

@property (nonatomic, strong) UILabel* infoType;

@property (nonatomic, strong) UIImageView* infoIcon;

@property (nonatomic, strong) UIImageView* triangle;

@property (nonatomic, strong) EZEventBlock clicked;

@property (nonatomic, strong) UIView* graySep;

@property (nonatomic, assign) BOOL selected;

- (void) setCount:(int) count;

- (void) setSelected:(BOOL)selected;

@end
