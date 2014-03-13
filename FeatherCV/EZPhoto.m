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

- (id) init
{
    self = [super init];
    _conversations = [[NSMutableArray alloc] init];
    return self;
    
}

- (NSArray*) conversationToJson
{
    //if(!_conversations)
    //    return nil;
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in _conversations){
        [res addObject:@{
                         @"text":[dict objectForKey:@"text"],
                         @"date":isoDateFormat([dict objectForKey:@"date"])
                         }];
    }
    return res;
}

- (NSArray*) conversationFromJson:(NSArray*)jsons
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in jsons){
        [res addObject:@{
                         @"text":[dict objectForKey:@"text"],
                         @"date":isoStr2Date([dict objectForKey:@"date"])
                         }];
    }
    return res;
}


- (NSArray*) localRelationsToJson
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:[pt toLocalJson]];
    }
    return res;
}

- (NSArray*) relationsToJson
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:pt.photoID];
    }
    return res;
}

- (NSArray*) relationsUserID
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:pt.personID];
    }
    return res;
}

//Have different needs
- (NSDictionary*) toLocalJson
{
    return @{
             //@"id":_photoID,
             @"photoID":null2Empty(_photoID),
             @"personID":null2Empty(_personID),
             @"assetURL":null2Empty(_assetURL),
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"altitude":@(_altitude),
             @"uploaded":@(_uploaded),
             @"shareStatus":@(_shareStatus),
             @"width":@(_size.width),
             @"height":@(_size.height),
             @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
             @"conversations":[self conversationToJson],
             @"photoRelations":[self localRelationsToJson],
             @"relationUsers":[self relationsUserID],
             @"screenURL":null2Empty([self screenURL]),
             @"liked":_liked.count?_liked:@[],
             @"uploadInfoSuccess":@(_uploadInfoSuccess),
             @"uploadPhotoSuccess":@(_uploadPhotoSuccess),
             @"deleted":@(_deleted)
             };
}

- (NSDictionary*) toJson
{
    if(_photoID){
        return @{
             //@"id":_photoID,
             @"photoID":null2Empty(_photoID),
             @"personID":null2Empty(_personID),
             @"assetURL":null2Empty(_assetURL),
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"altitude":@(_altitude),
             @"uploaded":@(_uploaded),
             @"shareStatus":@(_shareStatus),
             @"width":@(_size.width),
             @"height":@(_size.height),
             @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
             @"conversations":[self conversationToJson],
             @"photoRelations":[self relationsToJson],
             @"relationUsers":[self relationsUserID],
             //@"screenURL":[self screenURL],
             @"liked":_liked.count?_liked:@[]
                 };
    }else{
        return @{
                 //@"id":_photoID,
                 @"personID":null2Empty(_personID),
                 @"assetURL":null2Empty(_assetURL),
                 @"longtitude":@(_longitude),
                 @"latitude":@(_latitude),
                 @"altitude":@(_altitude),
                 @"uploaded":@(_uploaded),
                 @"shareStatus":@(_shareStatus),
                 @"width":@(_size.width),
                 @"height":@(_size.height),
                 @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
                 @"conversations":[self conversationToJson],
                 @"photoRelations":[self relationsToJson],
                 @"relationUsers":[self relationsUserID],
                 //@"screenURL":[self screenURL],
                 @"liked":_liked.count?_liked:@[]
                 };

    }
}

- (void) fromJson:(NSDictionary*)dict
{
    EZDEBUG(@"json raw string:%@", dict);
    _personID = [dict objectForKey:@"personID"];
    //[[EZDataUtil getInstance] getPersonID:personID success:^(NSArray* ps){
    //    _owner = [ps objectAtIndex:0];
    //} failure:^(NSError* err){
    //    EZDEBUG(@"Error to find a person");
    //}];
    _photoID = [dict objectForKey:@"photoID"];
    _srcPhotoID = [dict objectForKey:@"srcPhotoID"];
    _assetURL = [dict objectForKey:@"assetURL"];
    _longitude = [[dict objectForKey:@"longitude"] doubleValue];
    _latitude = [[dict objectForKey:@"latitude"] doubleValue];
    _altitude = [[dict objectForKey:@"altitude"] doubleValue];
    _uploaded = [[dict objectForKey:@"uploaded"] integerValue];
    _shareStatus = [[dict objectForKey:@"shareStatus"] intValue];
    _createdTime = isoStr2Date([dict objectForKey:@"createdTime"]);
    _screenURL = [dict objectForKey:@"screenURL"];
    _thumbURL = url2thumb(_screenURL);
    _conversations = [self conversationFromJson:[dict objectForKey:@"conversations"]];
    _liked =[NSMutableArray arrayWithArray:[dict objectForKey:@"liked"]];
    CGFloat width = [[dict objectForKey:@"width"] floatValue];
    CGFloat height = [[dict objectForKey:@"height"] floatValue];

    _size = CGSizeMake(width, height);
    EZDEBUG(@"The serialized size:%@, screenURL:%@", NSStringFromCGSize(_size), _screenURL);
    NSArray* photoRelation = [dict objectForKey:@"photoRelations"];
    EZDEBUG(@"Photo count:%i", photoRelation.count);
    if(photoRelation.count > 0){
        _photoRelations = [[NSMutableArray alloc] initWithCapacity:photoRelation.count];
        for(int i = 0; i < photoRelation.count; i ++){
            NSDictionary* dict = [photoRelation objectAtIndex:i];
            EZPhoto* photo = [[EZPhoto alloc] init];
            [photo fromJson:dict];
            [_photoRelations addObject:photo];
        }
    }
    EZDEBUG(@"The created date is:%@", _createdTime);
}


- (UIImage*) getThumbnail
{
    //return [[UIImage alloc] initWithCGImage:[_asset aspectRatioThumbnail]];
    return nil;
}

/**
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
 **/

/**
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
**/

- (UIImage*) getScreenImage
{
    //NSURL* fileURL = str2url(_assetURL);
    return  [UIImage imageWithContentsOfFile:_assetURL];
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
