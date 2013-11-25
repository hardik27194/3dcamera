//
//  EZBaseCollectionPage.h
//  Feather
//
//  Created by xietian on 13-10-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZBaseCollectionPage : UICollectionViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UILabel* totalEntries;
@property (nonatomic, strong) UILabel* monthCount;
@property (nonatomic, strong) UILabel* weekCount;
@property (nonatomic, strong) UILabel* dailyCount;
@property (nonatomic, strong) UIView* container;

- (void) createHiddenButton;

@end
