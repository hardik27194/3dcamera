//
//  EZContactCell.h
//  Feather
//
//  Created by xietian on 13-10-16.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZClickImage.h"
#import "EZClickView.h"

@interface EZContactCell : UICollectionViewCell

@property(nonatomic, strong) UILabel* name;

@property(nonatomic, strong) UIView* border;

@property(nonatomic, strong) EZClickView* inviteButton;

@property(nonatomic, strong) EZClickImage* headIcon;

@end
