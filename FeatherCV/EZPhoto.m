//
//  EZPhoto.m
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPhoto.h"
#import "EZDataUtil.h"
#import "EZThreadUtility.h"

@implementation EZPhoto


- (UIImage*) getThumbnail
{
    return [[UIImage alloc] initWithCGImage:[_asset aspectRatioThumbnail]];
}


- (UIImage*) getOriginalImage
{
    ALAssetRepresentation *assetRepresentation = [_asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    
    ALAssetOrientation orientation = (ALAssetOrientation)[[_asset valueForProperty:ALAssetPropertyOrientation] integerValue];
    EZDEBUG(@"photo orientation:%i", orientation);
    return fullScreenImage;

}

- (UIImage*) getScreenImage
{
    ALAssetRepresentation *assetRepresentation = [_asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    
    ALAssetOrientation orientation = (ALAssetOrientation)[[_asset valueForProperty:ALAssetPropertyOrientation] integerValue];
    EZDEBUG(@"photo orientation:%i", orientation);
    return fullScreenImage;

}

- (void) getAsyncImage:(EZEventBlock)block
{
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        UIImage* img = [self getScreenImage];
        dispatch_async(dispatch_get_main_queue(), ^(){
            block(img);
        });
    }];
}

@end
