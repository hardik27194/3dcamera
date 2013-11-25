//
//  EZImageFileCache.h
//  Feather
//
//  Created by xietian on 13-11-1.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAppConstants.h"

//What's the purpose of this class?
//Store the file to the cache directory.
//Only store it in my specified format.
//Have a LRU map, only the lastest will get stored.
//In current implementation, only use a simply NSDictionary to get the job done
@interface EZImageFileCache : NSObject

@property (nonatomic, strong) NSMutableDictionary* cache;

@property (nonatomic, strong) NSMutableArray* hitQueue;

@property (nonatomic, assign) int cacheLimit;

//The cached file name template
@property (nonatomic, strong) NSString* cachedFileNameTemp;

+ (EZImageFileCache*) getInstance;

//Returned the stored URL
- (NSString*) storeImage:(UIImage*)img key:(NSString*)key;

- (NSString*) getImage:(NSString*)key;

@end
