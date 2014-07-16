//
//  EZAddFriendCell.h
//  FeatherCV
//
//  Created by xietian on 14-7-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZAddFriendCell : UITableViewCell

@property (nonatomic, strong) UIButton* addButton;

@property (nonatomic, strong) EZEventBlock addClicked;

- (void) addClicked:(id)sender;

@end
