//
//  EZImageFileCache.m
//  Feather
//
//  Created by xietian on 13-11-1.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZImageFileCache.h"
#import "EZFileUtil.h"

@interface EZCacheEntry : NSObject

@property (nonatomic, assign) int hitCount;

@property (nonatomic, strong) id attachment;

@property (nonatomic, strong) NSString* cacheFileName;

@property (nonatomic, strong) NSString* key;

- (void) recyle;

@end

@implementation EZCacheEntry

//This object will get reused
- (void) recyle
{
    _hitCount = 0;
    _attachment = nil;
    _key = nil;
}

@end


static EZImageFileCache* instance;

static int imageFileCount = 0;

@implementation EZImageFileCache

+ (EZImageFileCache*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZImageFileCache alloc] init];
        //instance.cacheLimit = 100;
        
    });
    return instance;
}

- (id) init
{
    self = [super init];
    _cacheLimit = 5;
    _cache = [[NSMutableDictionary alloc] initWithCapacity:_cacheLimit];
    _hitQueue = [[NSMutableArray alloc] initWithCapacity:_cacheLimit];
    _cachedFileNameTemp = @"featch_cached_image%i";
    return self;
}


- (NSString*) storeImage:(UIImage *)img key:(NSString *)key
{
    NSString* storedName = [NSString stringWithFormat:_cachedFileNameTemp, key.hash];
    EZDEBUG(@"storedName:%@", storedName);
    NSString* urlString  = [[NSURL fileURLWithPath:[EZFileUtil saveImageToCacheWithName:img filename:storedName]] absoluteString];
    EZCacheEntry* ce = [[EZCacheEntry alloc] init];
    ce.attachment = urlString;
    ce.key = key;
    ce.cacheFileName = storedName;
    [_hitQueue insertObject:ce atIndex:0];
    [_cache setObject:ce forKey:key];
    return urlString;
}

//If the system pass the same key, I think it try to overwrite the old
- (NSString*) storeImageOld:(UIImage*)img key:(NSString*)key
{
    NSString* storedName = [NSString stringWithFormat:_cachedFileNameTemp, imageFileCount++];
    
    EZCacheEntry* ce = [_cache objectForKey:key];
    if(ce){
        [EZFileUtil saveImageToCacheWithName:img filename:ce.cacheFileName];
        ce.hitCount = 0;
        return [self getImage:key];
    }
    if(_hitQueue.count >= _cacheLimit){
        ce = [_hitQueue lastObject];
        [_hitQueue removeLastObject];
        storedName = ce.cacheFileName;
        [_cache removeObjectForKey:ce.key];
        EZDEBUG(@"removed cache is:%@, hitCount:%i", ce.key, ce.hitCount);
        //storedName = ce.cacheFileName;
        [ce recyle];
        
    }
    if(!ce){
        ce = [[EZCacheEntry alloc] init];
    }
    
    NSString* urlString  = [[NSURL fileURLWithPath:[EZFileUtil saveImageToCacheWithName:img filename:storedName]] absoluteString];
    ce.attachment = urlString;
    ce.key = key;
    ce.cacheFileName = storedName;
    [_hitQueue insertObject:ce atIndex:0];
    [_cache setObject:ce forKey:key];
    return urlString;
}

- (NSString*) getImage:(NSString*)key
{
    @synchronized(self){
        EZCacheEntry* ce = [_cache objectForKey:key];
        if(ce){
            ce.hitCount ++;
            [_hitQueue removeObject:ce];
            [_hitQueue insertObject:ce atIndex:0];
            return ce.attachment;
        }
        return nil;
    }
}


@end
