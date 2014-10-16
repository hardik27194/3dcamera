//
//  EZDetailPage.h
//  3DCamera
//
//  Created by xietian on 14-8-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>


@class EZStoredPhoto;
@class EZShotTask;
@interface EZDetailPage : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, strong) EZShotTask* task;

@property (nonatomic, strong) UILabel* switchTitle;

@property (nonatomic, strong) UISwitch* switchBtn;

@property (nonatomic, strong) EZEventBlock taskChanged;

- (id) initWithTask:(EZShotTask*)task;

@end
