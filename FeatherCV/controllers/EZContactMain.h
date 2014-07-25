//
//  EZContactMain.h
//  FeatherCV
//
//  Created by xietian on 14-6-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kNormalPos,
    kStripeShow,
    kFullProfile
} EZProfileStatus;


//typedef enum {

//} EZTabStatus;

@class EZPerson;
@class EZProfileView;
@interface EZContactMain : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* persons;

@property (nonatomic, strong) EZProfileView* profileView;

@property (nonatomic, assign) EZProfileStatus profileStatus;

@property (nonatomic, assign) EZContactDisplayType displayType;

@property (nonatomic, assign) EZTabType tabType;

@property (nonatomic, strong) EZPerson* person;

@end
