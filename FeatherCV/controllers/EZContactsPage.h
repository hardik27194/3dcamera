//
//  EZContactsPage.h
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZContactsPage : UICollectionViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray* contacts;

- (EZContactsPage*) initPage;

@property (nonatomic, strong) UILabel* totalEntries;
@property (nonatomic, strong) UILabel* monthCount;
@property (nonatomic, strong) UILabel* weekCount;
@property (nonatomic, strong) UILabel* dailyCount;
@property (nonatomic, strong) UIView* container;

@end
