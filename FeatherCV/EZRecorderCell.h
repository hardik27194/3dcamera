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

@property (nonatomic, strong) UIButton* name;

@property (nonatomic, strong) EZEventBlock iconClicked;

@property (nonatomic, strong) EZEventBlock starClicked;

@property (nonatomic, strong) EZEventBlock nameClicked;

@property (nonatomic, strong) UIView* tapView;

@property (nonatomic, strong) UIImageView* starImg;
//
- (void) setStarred:(BOOL)starred;

- (void) hideStar:(BOOL)hideStar;

- (void) enableTapView;

@end
