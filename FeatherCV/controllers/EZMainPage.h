//
//  EZMainPage.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAppConstants.h"

@class EZTiltMainView;
@interface EZMainPage : UITableViewController

//Currently keep everything as simple as possible.
//
@property (nonatomic, strong) NSArray* combinedPhotos;

@property (nonatomic, strong) EZTiltMainView* tiltMain;

@end
