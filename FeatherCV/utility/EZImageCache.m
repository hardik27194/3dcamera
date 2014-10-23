//
//  EZImageCache.m
//  3DCamera
//
//  Created by xietian on 14-9-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZImageCache.h"
#import "EZFileUtil.h"
#import "EZExtender.h"
#import "UIImageView+AFNetworking.h"

@interface EZCacheEntry2 : NSObject

@property (nonatomic, assign) int hitCount;

@property (nonatomic, strong) id attachment;

@property (nonatomic, strong) NSString* cacheFileName;

@property (nonatomic, strong) NSString* key;

@property (nonatomic, strong) UIImage* image;

- (void) recyle;

@end

@implementation EZCacheEntry2

//This object will get reused
- (void) recyle
{
    _hitCount = 0;
    _attachment = nil;
    _key = nil;
    _image = nil;
}

- (void) dealloc
{
    EZDEBUG(@"removed cache");
}

@end



@implementation EZImageCache


- (id) initWithLimit:(int)cacheLimit
{
    self = [super init];
    _cacheLimit = cacheLimit;
    _cache = [[NSMutableDictionary alloc] initWithCapacity:_cacheLimit];
    _hitQueue = [[NSMutableArray alloc] initWithCapacity:_cacheLimit];
    //_cachedFileNameTemp = @"featch_cached_image%i";
    return self;

}

- (id) init
{
    return [self initWithLimit:40];
}

/**
- (NSString*) storeImage:(UIImage *)img key:(NSString *)key
{
    NSString* fileName = [NSString stringWithFormat:@"cache_%i.jpg", key.hash];
    NSString* urlString  = [[NSURL fileURLWithPath:[EZFileUtil saveToDocument:[img toJpegData:1.0] filename:fileName]] absoluteString];
    EZCacheEntry* ce = [[EZCacheEntry alloc] init];
    ce.attachment = urlString;
    ce.key = key;
    ce.cacheFileName = fileName;
    [_hitQueue insertObject:ce atIndex:0];
    [_cache setObject:ce forKey:key];
    return urlString;
}
**/
//If the system pass the same key, I think it try to overwrite the old
- (NSString*) storeImage:(UIImage*)img key:(NSString*)key
{
    NSString* fileName = [NSString stringWithFormat:@"cache_%i.jpg", key.hash];
    EZCacheEntry2* ce = [_cache objectForKey:key];
    if(ce){
        //[EZFileUtil saveImageToCacheWithName:img filename:ce.cacheFileName];
        ++ce.hitCount;
        //return [self getImage:key];
    }else{
        NSString* urlString  = [NSString stringWithFormat:@"file://%@", [EZFileUtil saveToDocument:[img toJpegData:.7] filename:fileName]];
        ce = [[EZCacheEntry2 alloc] init];
        ce.attachment = urlString;
        ce.key = key;
        ce.cacheFileName = fileName;
        ce.image = img;
        //EZDEBUG(@"before change queue:%i", _hitQueue.count);
        [_hitQueue insertObject:ce atIndex:0];
        [_cache setObject:ce forKey:key];
    }
    [self checkLimit];
    return ce.attachment;
}


- (void) checkLimit
{
    if(_hitQueue.count >= _cacheLimit){
        EZCacheEntry2* ce = [_hitQueue lastObject];
        [_hitQueue removeLastObject];
        //storedName = ce.cacheFileName;
        [_cache removeObjectForKey:ce.key];
        EZDEBUG(@"removed cache is:%@, hitCount:%i,_cache size:%i, queue size:%i", ce.key, ce.hitCount, _cache.count, _hitQueue.count);
        //storedName = ce.cacheFileName;
        //[ce recyle];
        
    }

}
- (NSString*) checkExist:(NSString*)key
{
    NSString* fileName = [NSString stringWithFormat:@"cache_%i.jpg", key.hash];
    if([EZFileUtil isExistInDocument:fileName]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName]; //Add the file name
        return filePath;

    }
    return nil;
}

- (UIImage*) getImage:(NSString*)key
{
    //@synchronized(self){
        EZCacheEntry2* ce = [_cache objectForKey:key];
        if(ce){
            ce.hitCount ++;
            [_hitQueue removeObject:ce];
            [_hitQueue insertObject:ce atIndex:0];
            //if(!ce.image){
            //    ce.image = [UIImage imageWithContentsOfFile:ce.cacheFileName];
            //}
            //return [UIImage imageWithContentsOfFile:ce.cacheFileName];
            return ce.image;
            //return ce.attachment;
        }else{
            NSString* existFile = [self checkExist:key];
            if(existFile){
                //UIImage* res = [UIImage imageWithContentsOfFile:existFile];
                //[self storeImage:res key:key];
                
                NSString* fileURL = [NSString stringWithFormat:@"file://%@", existFile];
                ce = [[EZCacheEntry2 alloc] init];
                ce.attachment = fileURL;
                ce.key = key;
                ce.cacheFileName = existFile;
                EZDEBUG(@"add exist file:%@", existFile);
                [_hitQueue insertObject:ce atIndex:0];
                [_cache setObject:ce forKey:key];
                ce.image = [UIImage imageWithContentsOfFile:ce.cacheFileName];
                //[self checkLimit];
                return ce.image;
                //return [UIImage imageWithContentsOfFile:ce.cacheFileName];
                
            }
        }
        return nil;
    //}
}


SINGLETON_FOR_CLASS(EZImageCache);

@end
