//
//  EZMainPage.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZScrollerView;
@interface EZMainPage : UIViewController<UITableViewDataSource, UITableViewDelegate>

//What kind of cell will displayed.
@property (nonatomic, strong) NSArray* motherMenus;

@property (nonatomic, strong) NSArray* childMenus;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) EZScrollerView* profileScroll;

@property (nonatomic, strong) EZScrollerView* recorderScroll;


@end
