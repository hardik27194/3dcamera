//
//  EZChatCell.h
//  FeatherCV
//
//  Created by xietian on 14-5-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZClickImage;
@interface EZChatCell : UITableViewCell

@property (nonatomic, strong) EZClickImage* headIcon;

@property (nonatomic, strong) UILabel* chatTime;

@property (nonatomic, strong) UILabel* chatLabel;

@end
