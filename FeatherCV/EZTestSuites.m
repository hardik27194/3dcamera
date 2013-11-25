//
//  EZTestSuites.m
//  Feather
//
//  Created by xietian on 13-10-29.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZTestSuites.h"
#import "EZGeoUtility.h"
#import "EZImageFileCache.h"
#import "EZDataUtil.h"

@implementation EZTestSuites

+ (void) testAll
{
    
    //[EZTestSuites testImageCache];
    //assert(false);
    [EZTestSuites testAssetFetch];
}

+ (void) testAssetFetch
{
    [[EZDataUtil getInstance] loadAlbumPhoto:0 limit:100 success:^(NSArray* photos){
        EZDEBUG(@"Total fetched:%i", photos.count);
    } failure:^(NSError* err){EZDEBUG(@"Error:%@", err);}];
}

+ (void) testGeoFetch
{
    [[EZGeoUtility getInstance] findCurrentLocation:^(CLLocation* loc){
        EZDEBUG(@"Get location:");
        [[EZGeoUtility getInstance] locationToAddress:loc success:^(NSString* addr){
            EZDEBUG(@"The returned address:%@", addr);
        } failure:^(id error){
            EZDEBUG(@"Error: %@", error);
        }];
        
    } once:YES];

}

+ (void) testImageCache
{
    UIImage* img = [UIImage imageNamed:@"img01.jpg"];
    NSString* imgURL = [[EZImageFileCache getInstance] storeImage:img key:@"file1"];
    EZDEBUG(@"imgURL firstTime:%@", imgURL);
    NSString* fetchBack = [[EZImageFileCache getInstance] getImage:@"file1"];
    EZDEBUG(@"imgURL fetchBack:%@", fetchBack);
    
    fetchBack = [[EZImageFileCache getInstance] getImage:@"file1"];
    EZDEBUG(@"imgURL fetchBack again:%@", fetchBack);
}


@end
