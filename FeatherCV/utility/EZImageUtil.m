//
//  EZImageUtil.m
//  3DCamera
//
//  Created by xietian on 14-9-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZImageUtil.h"
#import "EZImageCache.h"

@implementation EZImageUtil

- (id) init
{
    self = [super init];
    _imageOperationQueue = [[NSOperationQueue alloc] init];
    _imageOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    return self;
}


- (void) preloadImageURL:(NSURL *)url success:(EZEventBlock)success failed:(EZEventBlock)failed
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    UIImage *cachedImage = [[EZImageCache sharedEZImageCache] getImage:request.URL.absoluteString]; //[[[self class] sharedImageCache] cachedImageForRequest:request];
    if (cachedImage) {
        if (success) {
            success(cachedImage);
        }
        //self.af_imageRequestOperation = nil;
    } else {
        //self.image = placeholderImage;
        //__weak __typeof(self)weakSelf = self;
        AFHTTPRequestOperation* imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //[[[self class] sharedImageCache] cacheImage:responseObject forRequest:request];
            [[EZImageCache sharedEZImageCache] storeImage:responseObject key:[url absoluteString]];
            //UIImage *fetchBack = [[[self class] sharedImageCache] cachedImageForRequest:request];
            //EZDEBUG(@"Prefetch immediate fetch back:%@, %i, sharedCache:%i", url.absoluteString, (int)fetchBack, (int)[[self class] sharedImageCache]);
            if ([[request URL] isEqual:[operation.request URL]]) {
                if (success) {
                    success(responseObject);
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[request URL] isEqual:[operation.request URL]]) {
                if (failed) {
                    failed(error);
                }
            }
        }];
        [_imageOperationQueue addOperation:imageRequestOperation];
    }
}

SINGLETON_FOR_CLASS(EZImageUtil);

@end
