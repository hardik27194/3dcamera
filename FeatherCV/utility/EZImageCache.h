//
//  EZImageCache.h
//  3DCamera
//
//  Created by xietian on 14-9-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZImageCache : NSObject

SINGLETON_FOR_HEADER(EZImageCache);

@property (nonatomic, strong) NSMutableDictionary* cache;

@property (nonatomic, strong) NSMutableArray* hitQueue;

@property (nonatomic, assign) int cacheLimit;

//The cached file name template
//@property (nonatomic, strong) NSString* cachedFileNameTemp;

//Returned the stored URL
- (NSString*) storeImage:(UIImage*)img key:(NSString*)key;

- (UIImage*) getImage:(NSString*)key;

- (id) initWithLimit:(int)cacheLimit;

@end
