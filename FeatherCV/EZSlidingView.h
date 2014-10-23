//
//  EZSlidingView.h
//  3DCamera
//
//  Created by xietian on 14-10-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZSlidingView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray* menuItems;

@property (nonatomic, strong) NSArray* actionLists;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, weak) UIView* coverView;

- (id) initWithFrame:(CGRect)frame menuItems:(NSArray*)menuItems actionLists:(NSArray*)actionList;


- (void) dismiss:(BOOL)animated;

- (void) showInView:(UIView*)view animated:(BOOL)animated;

@end
