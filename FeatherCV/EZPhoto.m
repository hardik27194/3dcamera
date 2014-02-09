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
#import "EZDataUtil.h"

@implementation EZPhoto


- (NSDictionary*) toJson
{
    return @{
             //@"id":_photoID,
             @"personID":_owner.personID?_owner.personID:@"",
             @"assetURL":_assetURL?_assetURL:@"",
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"uploaded":@(_uploaded),
             @"createdTime":_createdTime?_createdTime:@""
                 };
}

- (void) fromJson:(NSDictionary*)dict
{
    EZDEBUG(@"json raw string:%@", dict);
    NSString* personID = [dict objectForKey:@"personID"];
    [[EZDataUtil getInstance] getPersonID:personID success:^(EZPerson* ps){
        _owner = ps;
    } failure:^(NSError* err){
        EZDEBUG(@"Error to find a person");
    }];
    _assetURL = [dict objectForKey:@"assetURL"];
    _longitude = [[dict objectForKey:@"longitude"] doubleValue];
    _latitude = [[dict objectForKey:@"latitude"] doubleValue];
    _uploaded = [[dict objectForKey:@"uploaded"] integerValue];
    _createdTime = [dict objectForKey:@"createdTime"];
    EZDEBUG(@"The created date is:%@", _createdTime);
}

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
