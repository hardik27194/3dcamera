//
//  EZRecorderCell.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZRecorderCell : UICollectionViewCell

@property (nonatomic, strong) UIButton* starButton;

@property (nonatomic, strong) UIButton* iconButton;

@property (nonatomic, strong) UILabel* measurement;

@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) EZEventBlock iconClicked;

@property (nonatomic, strong) EZEventBlock starClicked;

//
- (void) setStarred:(BOOL)starred;

- (void) hideStar:(BOOL)hideStar;

@end
