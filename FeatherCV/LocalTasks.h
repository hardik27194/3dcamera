//
//  LocalTasks.h
//  3DCamera
//
//  Created by xietian on 14-9-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalTasks : NSManagedObject

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSDictionary* payload;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSString * personID;

@end
