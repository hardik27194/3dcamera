//
//  EZTiltMainView.h
//  Feather
//
//  Created by xietian on 13-10-7.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAppConstants.h"
//What's the purpose of this class?
//Show the photo in a titled way.
//Use guesture to switch back and forth.
//I love this game.
@interface EZTiltMainView : UITableViewController

@property (nonatomic, strong) EZEventBlock recoverBack;

@end
