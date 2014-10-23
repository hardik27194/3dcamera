//
//  EZSlidingView.m
//  3DCamera
//
//  Created by xietian on 14-10-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSlidingView.h"

@implementation EZSlidingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id) initWithFrame:(CGRect)frame menuItems:(NSArray*)menuItems actionLists:(NSArray*)actionList
{
    self = [super initWithFrame:frame];
    _tableView = [[UITableView alloc] initWithFrame:(CGRect){0,0, frame.size.width, frame.size.height} style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellID"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuItems = menuItems;
    _actionLists = actionList;
    [self addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    return self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuItems.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSString* menuName = [_menuItems objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textColor = [EZColorScheme sharedEZColorScheme].systemTextColor;
    cell.textLabel.text = menuName;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZEventBlock action = [_actionLists objectAtIndex:indexPath.row];
    if(action){
        action(@(indexPath.row));
    }
}


- (void) dismiss:(BOOL)animated
{
    [UIView animateWithDuration:0.5 animations:^(){
        self.x = -self.width;
    } completion:^(BOOL completed){
        [_coverView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void) showInView:(UIView*)view animated:(BOOL)animated
{
    self.x = -self.width;
    _coverView = [view createCoverView:167791 color:RGBA(70, 70, 70, 128) below:nil tappedTarget:self action:@selector(coverTapped:)];
    [view addSubview:self];
    [UIView animateWithDuration:0.5 animations:^(){
        self.x = 0;
    }];
    
}


- (void) coverTapped:(UIView*)view
{
    [self dismiss:YES];
}
@end
