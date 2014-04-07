//
//  EZContactTableCell.h
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZClickImage;
@class EZClickView;
@interface EZContactTableCell : UITableViewCell

@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) EZClickImage* headIcon;

//The place will get clicked 
@property (nonatomic, strong) EZClickView* clickRegion;

@property (nonatomic, strong) UILabel* inviteButton;

@property (nonatomic, strong) EZEventBlock inviteClicked;

@property (nonatomic, strong) UILabel* photoCount;

- (void) fitLine;

@end
