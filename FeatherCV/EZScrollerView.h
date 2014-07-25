//
//  EZScrollerView.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZSeperator;
@interface EZScrollerView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray* views;

@property (nonatomic, assign) NSInteger currentPos;

@property (nonatomic, strong) EZEventBlock scrolledTo;

@property (nonatomic, strong) UIPageControl* pageControl;

@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, strong) EZSeperator* seperator;

@property (nonatomic, assign) BOOL hidePageControl;

@end
