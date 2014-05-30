//
//  EZTalkPage.h
//  FeatherCV
//
//  Created by xietian on 14-5-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EZPerson;
@class EZPhoto;

@interface EZTalkPage : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) EZPerson* otherPerson;

@property (nonatomic, strong) EZPhoto* talkingPhoto;

@property (nonatomic, strong) UITextView* inputRegion;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* chats;

@end
