//
//  EZContactTablePage.h
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZContactTablePage : UITableViewController


@property (nonatomic, strong) NSMutableArray* contacts;

//Will be called to load all the contacts from the directory.
- (void) reloadPersons;

- (void) displayContacts;

@end
