//
//  EZScrollController.h
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZScrollController : UIViewController<UIScrollViewDelegate>

- (id) initWithDetail:(UIImageView*)detail;

@property (nonatomic, strong) UIImageView* detail;

@property (nonatomic, assign) UIScrollView* scrollView;

@property (nonatomic, strong) EZEventBlock tappedBlock;

@end
