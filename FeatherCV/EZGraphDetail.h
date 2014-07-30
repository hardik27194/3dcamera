//
//  EZGraphDetail.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZRecordTypeDesc;
@interface EZGraphDetail : UIViewController<UIWebViewDelegate>

- (id) initWith:(EZRecordTypeDesc*)desc date:(NSDate*)date;

@property (nonatomic, strong) NSDate* checkDate;

@property (nonatomic, strong) EZRecordTypeDesc* desc;

@property (nonatomic, strong) UIWebView* webView;

@end
