//
//  EZContactCell.h
//  FeatherCV
//
//  Created by xietian on 14-6-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZClickImage.h"
/**
 Why do I use UIView rather than UITableViewCell?
 Because, UIView is more flexible.
 I can easily switch cell between.
 **/
@class  EZLineDrawingView;
@interface EZContactMainCell : UITableViewCell

@property (nonatomic, strong) EZClickImage* headIcon;

@property (nonatomic, strong) UIImageView* photoView;

@property (nonatomic, strong) UILabel* timeText;

@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) UILabel* otherName;

@property (nonatomic, strong) UILabel* signature;

@property (nonatomic, strong) EZLineDrawingView* paintTouchView;

@property (nonatomic, strong) UIButton* addButton;

@property (nonatomic, strong) EZEventBlock addClicked;

@end
