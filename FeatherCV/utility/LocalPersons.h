//
//  LocalPersons.h
//  FeatherCV
//
//  Created by xietian on 14-3-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalPersons : NSManagedObject

@property (nonatomic, retain) NSString * personID;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * payloads;

@end
