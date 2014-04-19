//
//  EZEnlargedView.h
//  FeatherCV
//
//  Created by xietian on 14-4-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZClickView.h"

@class EZClickImage;
@interface EZEnlargedView : EZClickView

@property (nonatomic, assign) BOOL isEnlarged;

@property (nonatomic, assign) CGFloat enlargeRatio;

@property (nonatomic, strong) UIImageView* clickImage;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) UIView* innerView;

- (id) initWithFrame:(CGRect)frame enlargeRatio:(CGFloat)enlargeRatio;

- (id) initWithFrame:(CGRect)frame innerView:(UIView*)innerView enlargeRatio:(CGFloat)enlargeRatio;

@end
