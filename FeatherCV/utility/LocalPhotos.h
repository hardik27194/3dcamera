//
//  LocalPhotos.h
//  FeatherCV
//
//  Created by xietian on 14-3-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalPhotos : NSManagedObject

@property (nonatomic, retain) NSMutableDictionary * payloads;
@property (nonatomic, retain) NSString * photoID;

@end
