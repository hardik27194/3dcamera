//
//  EZContactMain.h
//  FeatherCV
//
//  Created by xietian on 14-6-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZContactMain : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* persons;



@end
