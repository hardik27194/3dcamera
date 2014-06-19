//
//  EZPasswordFetcher.h
//  FeatherCV
//
//  Created by xietian on 14-6-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"

@interface EZPasswordFetcher : EZKeyboardController<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel* titleInfo;

@property (nonatomic, strong) UITextView* introduction;

@property (nonatomic, strong) UIView* smsCodeView;

@property (nonatomic, strong) UIView* passwordView;

@property (nonatomic, strong) UIScrollView* scrollContainer;

@property (nonatomic, strong) UIPageControl* pageControl;

@end
