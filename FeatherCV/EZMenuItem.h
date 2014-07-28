//
//  EZMenuItem.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZMenuItem : NSObject

- (id) initWith:(NSString*)menuName iconURL:(NSString*)iconURL selectedIconURL:(NSString*)selectedURL action:(EZEventBlock)action;

@property (nonatomic, strong) NSString* menuName;

@property (nonatomic, strong) NSString* iconURL;

@property (nonatomic, strong) NSString* selectedIconURL;

@property (nonatomic, assign) NSInteger notesCount;

@property (nonatomic, strong) EZEventBlock selectedAction;

@end
