    //
//  EZDataUtil.m
//  Feather
//
//  Created by xietian on 13-10-16.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#include <CoreLocation/CLLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "EZDataUtil.h"
#import "EZFileUtil.h"
#import "EZDisplayPhoto.h"
#import "EZGeoUtility.h"
#import "EZImageFileCache.h"
#import "EZDisplayPhoto.h"
#import "EZExtender.h"
#import "EZMessageCenter.h"
#import "EZNetworkUtility.h"
#import "EZExtender.h"
#import "UIImageView+AFNetworking.h"
#import "EZRegisterCtrl.h"
#import "EZCenterButton.h"
#import "EZDownloadHolder.h"
#import "AFNetworking.h"

#import "EZCoreAccessor.h"
#import "LocalPersons.h"
#import "LocalPhotos.h"
#import "EZMessageCenter.h"
#import "EZNote.h"
#import "EZLoginController.h"


@implementation EZAlbumResult

@end

@implementation EZDataUtil

+ (EZDataUtil*) getInstance
{
    static dispatch_once_t onceToken;
    static EZDataUtil* instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[EZDataUtil alloc] init];
    });
    return instance;
}



- (id) init
{
    self = [super init];
    _asyncQueue = dispatch_queue_create("album_fetch", DISPATCH_QUEUE_SERIAL);
    if (_assetLibaray == nil) {
        _assetLibaray = [[ALAssetsLibrary alloc] init];
    }
    _contacts = [[NSMutableArray alloc] init];
    _isoFormatter = [[NSDateFormatter alloc] init];
    _isoFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    _localPhotos = [[NSMutableArray alloc] init];
    _pendingPhotos = [[NSMutableArray alloc] init];
    _recievedNotify = [[NSMutableDictionary alloc] init];
    //Move to the persistent later.
    //Now keep it simple and stupid
    _pendingUploads = [[NSMutableArray alloc] init];
    _prefetchImage = [[UIImageView alloc] init];
    _pendingUserQuery = [[NSMutableSet alloc] init];
    _currentQueryUsers = [[NSMutableDictionary alloc] init];
    _pendingPersonCall = [[NSMutableDictionary alloc] init];
    _timeFormatter = [[NSDateFormatter alloc] init];
    _joinedUsers = [[NSMutableSet alloc] init];
    _notJoinedUsers = [[NSMutableSet alloc] init];
    _totalCover = [[EZClickView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _totalCover.enableTouchEffects = false;
    _totalCover.backgroundColor = [UIColor clearColor];
    _sortedUsers = [[NSMutableArray alloc] init];
    _sortedUserSets = [[NSMutableSet alloc] init];
    _downloadedImages = [[NSMutableDictionary alloc] init];
    _imageSerializer = [AFImageResponseSerializer serializer];
    [_timeFormatter setDateStyle:NSDateFormatterShortStyle];
    [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_timeFormatter setDoesRelativeDateFormatting:YES];
    _currentPhotos = [[NSMutableArray alloc] init];
    _naviBarBlur = [[LFGlassView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 64)];
    _naviBarBlur.blurRadius = 20.0;
    _cachedPointer = [[NSMutableDictionary alloc] init];
    return self;
}



- (void) jumpCycleAnimation:(EZEventBlock)callBack
{
    if(!_contactButton){
        _contactButton = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _contactButton.backgroundColor = randBack(nil);
        [_contactButton enableRoundImage];
        //[TopView addSubview:_contactButton];
    }
    _contactButton.center = _centerButton.center;
    [TopView addSubview:_totalCover];
    [TopView addSubview:_contactButton];
    __weak EZDataUtil* weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:.5 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        [_contactButton moveY:-100];
    } completion:nil];
    
    
    
    EZEventBlock animateBlock = ^(id obj){
        [weakSelf.totalCover removeFromSuperview];
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            weakSelf.contactButton.center = weakSelf.centerButton.center;
        } completion:^(BOOL completed){
            [weakSelf.contactButton removeFromSuperview];
        }];
    };
    _totalCover.pressedBlock = ^(UIView* sender){
        EZDEBUG(@"_total cover clicked");
        animateBlock(nil);
    };
    
    EZEventBlock localCallBack = callBack;
    _contactButton.pressedBlock = ^(UIView* sender){
        animateBlock(nil);
        localCallBack(nil);
    };
  
    
}

- (void) callPendingQuery:(EZPerson*)ps
{
    NSMutableArray* calls = [_pendingPersonCall objectForKey:ps.personID];
    EZDEBUG(@"Pending call:%i", calls.count);
    for(EZEventBlock blk in calls){
        blk(ps);
    }
    [calls removeAllObjects];
}

- (EZPerson*) addPersonToStore:(NSDictionary*)pdict isQuerying:(BOOL)query
{
    EZPerson* ps = [_currentQueryUsers objectForKey:[pdict objectForKey:@"personID"]];
    if(!ps){
        ps = [[EZPerson alloc] init];
        [_currentQueryUsers setObject:ps forKey:[pdict objectForKey:@"personID"]];
    }
    [ps fromJson:pdict];
    ps.isQuerying = query;
    //[_currentQueryUsers setValue:ps forKey:ps.personID];
    return ps;
}

//Learn to combine the call
- (void) queryPendingPerson
{
    if(_queryingCount){
        EZDEBUG(@"quit for querying:%i", _queryingCount);
        return;
    }
    
    if(!_pendingUserQuery.count){
        return;
    }
    _queryingCount = true;
    
    NSArray* dupIDs = [NSArray arrayWithArray:[_pendingUserQuery allObjects]];
    [_pendingUserQuery removeAllObjects];
    
    [self queryPersonIDs:dupIDs success:^(NSArray* arr){
        _queryingCount = false;
        EZDEBUG(@"successfully query:%i users back:%@", dupIDs.count, arr);
        if(!arr.count){
            return;
        }
        NSMutableArray* persons = [[NSMutableArray alloc] init];
            
        for(NSDictionary* pdict in arr){
            EZPerson* ps = [self addPersonToStore:pdict isQuerying:NO];
            //[_currentQueryUsers setValue:ps forKey:ps.personID];
            [_pendingUserQuery removeObject:ps.personID];
            [self callPendingQuery:ps];
            ps.joined = YES;
            if(ps.joined){
                [_joinedUsers addObject:ps.personID];
            }else{
                [_notJoinedUsers addObject:ps.personID];
            }
            [persons addObject:ps];
        }
        [self storeAllPersons:persons];
    } failure:^(id obj){
        EZDEBUG(@"upload persons:%@", obj);
        _queryingCount = false;
    }];
    
}





//Check the current status
- (BOOL) canUpload
{
    return true;
    if(!_wifiOnly){
        return _networkAvailable;
    }
    return _networkAvailable && (_networkStatus == AFNetworkReachabilityStatusReachableViaWiFi);
    
}

- (void) populatePersons:(NSArray*)json persons:(NSArray*)persons
{
    EZDEBUG(@"Returned json count:%i, person count:%i", json.count, persons.count);
    for(int i = 0; i < json.count; i++){
        NSDictionary* dict = [json objectAtIndex:i];
        EZPerson* ps = [persons objectAtIndex:i];
        ps.uploaded = true;
        NSString* localName = ps.name;
        [ps fromJson:dict];
        int joinFlag = [[dict objectForKey:@"joined"] intValue];
        if( joinFlag != 1 && localName){
            ps.name = localName;
        }
        if(joinFlag == 1){
            [_joinedUsers addObject:ps.personID];
        }else if(joinFlag == 0){
            [_notJoinedUsers addObject:ps.personID];
        }
        [_currentQueryUsers setObject:ps forKey:ps.personID];
        EZDEBUG(@"jointed time :%@ ", ps.joinedTime);
    }
}



//Upload Contacts.
- (void) uploadContacts:(NSArray*)contacts success:(EZEventBlock)succss failure:(EZEventBlock)failure
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for(EZPerson* ps in contacts){
        [arr addObject:[ps toJson]];
    }
    [EZNetworkUtility postJson:@"person/info" parameters:@{@"cmd":@"upload",@"persons":arr} complete:^(NSArray* array){
        //EZDEBUG(@"All the returned info:%@", array);
        [self populatePersons:array persons:contacts];
        succss(contacts);
    } failblk:failure];
}

- (void) registerUser:(NSDictionary*)person success:(EZEventBlock)success error:(EZEventBlock)error
{
    [EZNetworkUtility postJson:@"register" parameters:person complete:^(NSDictionary* dict){
        EZPerson* person = [self addPersonToStore:dict isQuerying:NO];
        self.currentPersonID  = person.personID;
        self.currentLoginPerson = person;
        EZDEBUG(@"Returned person id:%@", person.personID);
        success(person);
        [self storeAllPersons:@[person]];
        [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:nil];
    } failblk:error];
}

//The purpose of this functionality to make sure unregisterred user could keep inforamtion.
- (void) registerMockUser:(EZEventBlock)success error:(EZEventBlock)error
{
    [EZNetworkUtility postJson:@"register" parameters:@{@"mock":@(1)} complete:^(NSDictionary* dict){
        EZPerson* person = [self addPersonToStore:dict isQuerying:NO];
        self.currentPersonID  = person.personID;
        self.currentLoginPerson = person;
        EZDEBUG(@"Mocked person id:%@", person.personID);
        success(person);
        [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:nil];
    } failblk:error];
}


- (void) queryPersonIDs:(NSArray*)personIDs success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    [EZNetworkUtility postParameterAsJson:@"person/info"
                               parameters:@{@"cmd":@"personID",
                                        @"personIDs":personIDs
                                }
    complete:^(NSArray* persons){
        EZDEBUG(@"Photo size:%i",persons.count);
        NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:persons.count];
        for(NSDictionary* dict in persons){
            //EZPerson* person = [[EZPerson alloc] init];
            //[person fromJson:dict];
            [res addObject:dict];
            //[_currentQueryUsers setObject:person forKey:person.personID];
        }
        if(success){
            success(res);
        }
        } failblk:failure];

}
//
- (void) queryPhotos:(int)page pageSize:(int)pageSize otherID:(NSString *)otherID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    NSDictionary* parameters = @{
                        @"cmd":@"query",
                        @"startPage":@(page),
                        @"pageSize":@(pageSize)
                        };

    if(otherID){
        parameters = @{
          @"cmd":@"query",
          @"startPage":@(page),
          @"pageSize":@(pageSize),
          @"otherID":otherID
          };
    }
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:parameters complete:^(NSArray* photos){
                         EZDEBUG(@"Photo size:%i",photos.count);
                         NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:photos.count];
                         for(NSDictionary* dict in photos){
                             EZPhoto* photo = [[EZPhoto alloc] init];
                             [photo fromJson:dict];
                             EZDEBUG(@"Photo relationship:%i", photo.photoRelations.count);
                             if(!photo.photoRelations.count){
                                 [res addObject:photo];
                             }else{
                                 [res addObject:photo];
                                 for(int i = 1; i < photo.photoRelations.count; i++){
                                     EZPhoto* ph = [photo copy];//[[EZPhoto alloc] init];
                                     //[ph fromJson:dict];
                                     ph.photoRelations = @[[photo.photoRelations objectAtIndex:i]];
                                     [res addObject:ph];
                                 }
                             }
                         }
                         if(success){
                             success(res);
                         }
    
    } failblk:failure];
}


- (void) deletePhoto:(EZPhoto *)photoInfo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    NSDictionary* jsons =@{@"cmd":@"delete",@"photoID":photoInfo.photoID};
    EZDEBUG(@"upload info:%@", jsons);
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:jsons complete:^(id infos){
        success(nil);
    } failblk:^(NSError* err){
        EZDEBUG(@"Error:%@", err);
        if(failure){
            failure(err);
        }
    }];
}

//Only upload the photo messsage, without upload the image
//Make sure this is upload messgae function call.
//Don't return anything, but the photoID
- (void) uploadPhotoInfo:(NSArray *)photoInfo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    NSDictionary* jsons =@{@"cmd":@"update",@"photos":[self arrayToJson:photoInfo]};
    EZDEBUG(@"upload info:%@", jsons);
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:jsons complete:^(NSArray* arr){
        NSMutableArray* res = [[NSMutableArray alloc] init];
        for(int i = 0; i < arr.count; i ++){
            NSDictionary* dict = [arr objectAtIndex:i];
            EZDEBUG(@"dictionary:%@", dict);
            //photo.photoID = [arr objectAtIndex:i];
            //[photo fromJson:[arr objectAtIndex:i]];
            [res addObject:[dict objectForKey:@"photoID"]];
        }
        success(res);
    } failblk:^(NSError* err){
        EZDEBUG(@"Error:%@", err);
        if(failure){
            failure(err);
        }
    }];
}

- (NSArray*) arrayToJson:(NSArray*)arr
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(id obj in arr){
        [res addObject:[obj toJson]];
    }
    return res;
}

- (void) populateNotification:(NSDictionary*)dict
{
    NSString* type = [dict objectForKey:@"type"];
    EZNote* note = [[EZNote alloc] init];
    [note fromJson:dict];
    
    if(note.senderPerson){
        EZDEBUG(@"Sender Perosn is:%@, %@", note.senderPerson.personID, note.senderPerson.name);
        EZPerson* currPerson = [_currentQueryUsers objectForKey:note.senderPerson.personID];
        //if(currPerson){
        //    [currPerson fromJson:[dict objectForKey:@"person"]];
        if(!currPerson){
            //currPerson = note.person;
            [_currentQueryUsers setObject:note.senderPerson  forKey:note.senderPerson.personID];
            [self storeAllPersons:@[note.senderPerson]];
        }

    }
    
    EZDEBUG(@"notes dict like:%i, liked:%i, detail:%@", [[dict objectForKey:@"like"]boolValue] , note.like, dict);
    if([@"match" isEqualToString:type]){
        NSString* photoID = [dict objectForKey:@"srcID"];
        EZDEBUG(@"source id:%@", photoID);
        
    }else if([@"like" isEqualToString:type]){
        //MongoUtil.save('notes', {'type':'like','personID':str(photo['personID']),'photoID':photoID,"otherID":personID,"like":likeStr})
        //pid2person(note.otherID);
        EZDEBUG(@"find like notes, source id:%@", note.otherID);
    }else if([EZNoteJoined isEqualToString:note.type]){
        EZPerson* currPerson = [_currentQueryUsers objectForKey:note.otherID];
        if(currPerson){
            [currPerson fromJson:[dict objectForKey:@"person"]];
        }else{
            currPerson = note.person;
            [_currentQueryUsers setObject:currPerson forKey:note.person.personID];
        }
        currPerson.activityCount = 1;
        [self adjustActivity:currPerson.personID];
    }
    [[EZMessageCenter getInstance] postEvent:EZRecievedNotes attached:note];
}

- (void) queryNotify
{
    EZDEBUG(@"Begin query notify");
    //NSDictionary* dict = [photo toJson];

    if(_pauseUpload){
        EZDEBUG(@"pause notification for shot");
        return;
    }
    [EZNetworkUtility postJson:@"notify" parameters:nil complete:^(NSArray* notes){
        EZDEBUG("notes count:%i", notes.count);
        int count = 0;
        for(int i = 0; i < notes.count; i++){
            NSDictionary* dict = [notes objectAtIndex:i];
            NSDictionary* stored = [_recievedNotify objectForKey:[dict objectForKey:@"noteID"]];
            if(!stored){
                EZDEBUG(@"new notes:%@", dict);
                count ++;
                [_recievedNotify setObject:dict forKey:@"noteID"];
                [self populateNotification:dict];
            }
        }
        EZDEBUG(@"no notification count %i", count);
    } failblk:^(id err){
        EZDEBUG(@"Failed to query notification:%@", err);
    }];
}

- (void) exchangeWithPerson:(NSString*)matchPersonID photoID:(NSString *)photoID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"Begin call exchange photo");
    //NSDictionary* dict = [photo toJson];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if(matchPersonID){
        [dict setValue:matchPersonID forKey:@"personID"];
    }
    if(photoID){
        [dict setValue:photoID forKey:@"photoID"];
    }
    
    [EZNetworkUtility postJson:@"photo/exchange" parameters:dict complete:^(id ph){
        EZPhoto* pt = [[EZPhoto alloc] init];
        [pt fromJson:ph];
        EZDEBUG(@"returned photo screen:%@", pt.screenURL);
        success(pt);
    } failblk:failure];
    
}

//I will exchange photo with other user
- (void) exchangePhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"Begin call exchange photo");
    //NSDictionary* dict = [photo toJson];
    NSDictionary* dict = nil;
    if(photo.photoID){
        dict = @{@"photoID":photo.photoID} ;
    }else if(photo){
        dict = photo.toJson;
    }else{
        dict = @{};
    }
    
    [EZNetworkUtility postJson:@"photo/exchange" parameters:dict complete:^(id ph){
        EZPhoto* pt = [[EZPhoto alloc] init];
        [pt fromJson:ph];
        EZDEBUG(@"returned photo screen:%@", pt.screenURL);
        success(pt);
    } failblk:failure];
}

- (void) cancelPrematchPhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    if(!photo.photoID)
        return;
    NSDictionary* dict = @{
                           @"cmd":@"removeMatch",
                           @"photoID":photo.photoID
                           };
    [EZNetworkUtility postJson:@"photo/info" parameters:dict complete:^(id queryRes){
        EZDEBUG(@"canel Prematch Result:%@", queryRes);
        success(queryRes);
    } failblk:failure];

}

//I will load the small image first, then the large image
- (void) serialPreload:(NSString*)fullURL
{
    NSString* thumbURL = url2thumb(fullURL);
    [self preloadImage:thumbURL success:^(NSString* thumbURL){
        EZDEBUG(@"Load thumb success:%@", thumbURL);
        [self preloadImage:fullURL success:nil failed:nil];
    } failed:nil];
}

- (void) serialLoad:(NSString*)fullURL fullOk:(EZEventBlock)fullBlock thumbOk:(EZEventBlock)thumbOk pending:(EZEventBlock)pending failure:(EZEventBlock)failure
{
    NSString* localFull = [self preloadImage:fullURL success:fullBlock failed:failure];
    if(!localFull){
        NSString* thumbURL = url2thumb(fullURL);
        NSString* localThumb = [self preloadImage:thumbURL success:thumbOk failed:failure];
        if(!localThumb && pending){
                pending(nil);
        }
    }
    
}


- (void) downloadImage:(NSString*)fullURL downloader:(EZDownloadHolder*)holder
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:str2url(fullURL)];
    //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* filePath = [EZFileUtil getCacheFileName:holder.filename];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        EZDEBUG(@"successfully downloaded");
        NSString* fileURL = [NSString stringWithFormat:@"file://%@", filePath];
        holder.downloaded = fileURL;
        [holder callSuccess];
        holder.isDownloading = false;
        //NSLog(@"SUCCCESSFULL IMG RETRIEVE to %@!",path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        EZDEBUG(@"fail to download:%@, error:%@", fullURL, error);
        [holder callFailure:error];
        holder.isDownloading = false;
        // Deal with failure
    }];//[[AFHTTPRequestOperation alloc] initWithRequest:request];
                                         
   // NSString* path=[@"/PATH/TO/APP" stringByAppendingPathComponent: imageNameToDisk];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation start];
    EZDEBUG(@"Should started the downloading.");
}


- (void) downloadImageOld:(NSString*)fullURL downloader:(EZDownloadHolder*)holder
{
    //EZDEBUG(@"downloadImage get called");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:str2url(fullURL)];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = _imageSerializer;
    
    __weak EZDownloadHolder* weakHolder = holder;
    holder.requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage* download = responseObject;
        EZDEBUG("Image size:%@", NSStringFromCGSize(download.size));
        if(responseObject){
            NSString* filePath = [EZFileUtil saveImageToCache:download filename:holder.filename];
            NSString* fileURL = [NSString stringWithFormat:@"file://%@", filePath];
            weakHolder.downloaded = fileURL;
            [weakHolder callSuccess];
        }else{
            [weakHolder callFailure:@"fail to download"];
        }
        weakHolder.isDownloading = false;
        
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        EZDEBUG(@"fail to download:%@, error:%@", fullURL, error);
        [weakHolder callFailure:error];
        weakHolder.isDownloading = false;
    }];//[[AFHTTPRequestOperation alloc] initWithRequest:request];
    //EZDEBUG(@"request object:%i", (int)holder);
    [holder.requestOperation start];
    //[holder.requestOperation ]

}


- (NSString*) fileNameFromURL:(NSString*)url
{
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.location != NSNotFound){
        //NSRange fetchHead;
        //fetchHead.length = range.location;
        //fetchHead.location = 0;
        //NSString* header = [normalURL substringToIndex:range.location];
        NSString* ender = [url substringFromIndex:range.location + 1];
        //res =[NSString stringWithFormat:@"%@%@%@",header,@"tb",ender];
        //EZDEBUG(@"Substring is:%@", res);
        return ender;
    }
    return url;
}

//Return local file name
- (NSString*) preloadImage:(NSString*)fullURL success:(EZEventBlock)success failed:(EZEventBlock)failed
{
    EZDownloadHolder* holder =  [_downloadedImages objectForKey:fullURL];
    if(fullURL == nil){
        //failed(@"Null URL");
        if(failed){
            failed(@"failure for nil");
        }
        return nil;
       
    }
    if(holder == nil){
        NSString* fileName = [self fileNameFromURL:fullURL];
        holder = [[EZDownloadHolder alloc] init];
        [_downloadedImages setObject:holder forKey:fullURL];
        holder.filename = fileName;
        holder.downloaded = [EZFileUtil isExistInCache:fileName];
    }
    EZDEBUG(@"File in cache:%@", holder.downloaded);
    if(!holder.downloaded){
        //return holder.downloaded;
        [holder insertSuccess:success];
        [holder insertFailure:failed];
        //EZDEBUG(@"not downloaded success size:%i, failure size:%i, holder:%i", holder.success.count, holder.failures.count, (int)holder);
        //[EZNetworkUtility download:fullURL complete:^(NSData* image){
            
        //} failblk:^(NSError* err){
        
        //}];
        if(!holder.isDownloading){
            holder.isDownloading = true;
            [self downloadImage:fullURL downloader:holder];
        }
        return nil;
    }else{
        if(success){
            success(holder.downloaded);
        }
        return holder.downloaded;
    }
}

- (void) uploadAvatar:(UIImage*)img success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    
    NSString* storedFile =[EZFileUtil saveImageToCache:img];
    [EZNetworkUtility upload:baseUploadURL parameters:@{} file:storedFile complete:^(id obj){
        NSString* screenURL = [obj objectForKey:@"avatar"];
        EZDEBUG(@"uploaded avatar URL:%@", screenURL);
        currentLoginUser.avatar = screenURL;
        success(screenURL);
    } error:failure progress:^(CGFloat percent){
        EZDEBUG(@"The uploaded percent:%f", percent);
    }];
}


- (NSString*) urlToThumbURL:(NSString *)normalURL
{
    //NSArray* splitted = [normalURL componentsSeparatedByString:@"/"];
    NSString* res = nil;
    //if(splitted.count > 0){
    //NSString* fileName = [splitted objectAtIndex:splitted.count - 1];
    //NSArray* splitStrs = [normalURL componentsSeparatedByString:@"."];
    
    //NSString* changedFileName = [NSString stringWithFormat:@"%@tb", [splitStrs objectAtIndex:splitStrs.count - 2]];
    NSRange redirectRange = [normalURL rangeOfString:@"photourl"];
    if(redirectRange.location != NSNotFound){
        return normalURL;
    }
    NSRange range = [normalURL rangeOfString:@"." options:NSBackwardsSearch];
    if(range.location != NSNotFound){
        //NSRange fetchHead;
        //fetchHead.length = range.location;
        //fetchHead.location = 0;
        NSString* header = [normalURL substringToIndex:range.location];
        NSString* ender = [normalURL substringFromIndex:range.location];
        res =[NSString stringWithFormat:@"%@%@%@",header,@"tb",ender];
        EZDEBUG(@"Substring is:%@", res);
    }
    return res;
}

- (void) uploadPhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    //NSDictionary* jsonInfo = [photo toJson];
    EZDEBUG(@"upload id:%@, storedFile:%@",photo.photoID, photo.assetURL);
    NSString* storedFile =  photo.assetURL;//[EZFileUtil saveImageToCache:[photo getScreenImage]];
    if(photo.photoID && [photo.assetURL isNotEmpty]){
        [EZNetworkUtility upload:baseUploadURL parameters:@{@"photoID":photo.photoID} file:storedFile complete:^(id obj){
            NSString* screenURL = [obj objectForKey:@"screenURL"];
            photo.screenURL = screenURL;
            photo.uploaded = TRUE;
            EZDEBUG(@"uploaded id:%@ screenURL:%@", screenURL, photo.photoID);
            success(photo);
        } error:failure progress:^(CGFloat percent){
            EZDEBUG(@"The uploaded percent:%f", percent);
            if(photo.progress){
                photo.progress(@(percent));
            }
        }];
    }else{
        EZDEBUG(@"photo have no id, waiting for id or not URL");
        if(failure){
            failure(@"photo have no id, waiting for id or not URL");
        }
    }
}

//What's the purpose of this
//Whether we allow the login page to show off or not.
//Why do we ask them to register
//Login or register can 
- (void) triggerLogin:(EZEventBlock)success failure:(EZEventBlock)failure reason:(NSString*)reason isLogin:(BOOL)isLogin
{
    [EZDataUtil getInstance].centerButton.hidden = YES;

    //if(isLogin){
    //    EZLoginController* loginCtl = [[EZLoginController alloc] init];
    //    UIViewController* presenter = [EZUIUtility topMostController];
    //    [presenter presentViewController:loginCtl animated:YES completion:nil];
        
    //}else{
    
    if(isLogin){
        EZLoginController* login = [[EZLoginController alloc] init];
        UIViewController* presenter = [EZUIUtility topMostController];
        [presenter presentViewController:login animated:YES completion:nil];
        [[EZMessageCenter getInstance] registerEvent:EZUserAuthenticated block:^(EZPerson* ps){
            EZDEBUG(@"dismiss login person:%@, avatar:%@", ps.name, ps.avatar);
            //[login dismissViewControllerAnimated:NO completion:nil];
        }];
    }else{
        EZRegisterCtrl* registerCtl = [[EZRegisterCtrl alloc] init];
        UIViewController* presenter = [EZUIUtility topMostController];
        [presenter presentViewController:registerCtl animated:YES completion:nil];
        [[EZMessageCenter getInstance] registerEvent:EZUserAuthenticated block:^(EZPerson* ps){
            EZDEBUG(@"dismiss login person:%@, avatar:%@", ps.name, ps.avatar);
            //[registerCtl dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}


- (void) loginUser:(NSDictionary*)loginInfo success:(EZEventBlock)success error:(EZEventBlock)error
{
    [EZNetworkUtility postJson:@"login" parameters:loginInfo complete:^(NSDictionary* dict){
        EZPerson* person = [self addPersonToStore:dict isQuerying:NO];//[[EZPerson alloc] init];
        //[person fromJson:dict];
        self.currentPersonID = person.personID;
        self.currentLoginPerson = person;
        [self storeAllPersons:@[person]];
        success(person);
    } failblk:error];
}

//called at logout, so that no user trace will left.
- (void) cleanLogin
{
    EZDEBUG(@"Will clean the session");
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"CurrentSessionID"];
}

- (void) setCurrentPersonID:(NSString *)currentPersonID
{
    [[NSUserDefaults standardUserDefaults] setObject:currentPersonID forKey:@"CurrentSessionID"];
    NSString* fetchedBack = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentSessionID"];
    _currentPersonID = currentPersonID;
    EZDEBUG(@"stored:%@, fetched:%@", currentPersonID, fetchedBack);
}

- (NSString*) getCurrentPersonID
{
    if(!_currentPersonID){
        _currentPersonID = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentSessionID"];
    }
    if(_currentPersonID && !_currentLoginPerson){
        [self getPersonByID:_currentPersonID success:^(EZPerson* ps){
            //EZDEBUG(@"loaded person count:%i", ps.count);
            EZDEBUG(@"Current person name:%@", ps.name);
            _currentLoginPerson = ps;
        }];
    }
    EZDEBUG(@"Current PersonID:%@, person name:%@", _currentPersonID, _currentLoginPerson.name);
    return _currentPersonID;
}

//Will load Friends
//Let me write down the logic when I am in the context now.
//1. I will do following thing when user start my app.
//Load the contacts from the phone book.
//In the meanwhile, I will upload the phone book info to the server side.
//What will happen?
//At the server side I will check whether this user is already login or not.
//If he already login, fetch it's information like avartar and other information back.
//Yes, The more I write the more love I have toward my Apps.
//Yes, It is my App, just like it is my life and it is my Child.
//This time, it is real. What I do define who am I.
//Do it like Steve Jobs toward his customer.
//I love this game.
- (void) loadFriends:(EZEventBlock)success failure:(EZEventBlock)failure
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        //success([self getAllContacts]);
        [self getAllContacts:success];
    });
}

- (NSArray*) getSortedPersons:(EZEventBlock)successBlck
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    NSMutableArray* pids = [[NSMutableArray alloc] init];
    [pids addObject:currentLoginID];
    
    [pids addObjectsFromArray:_sortedUsers];
    [pids addObjectsFromArray:_currentQueryUsers.allKeys];
    //[pids addObjectsFromArray:[_joinedUsers allObjects]];
    [pids addObjectsFromArray:_notJoinedUsers.allObjects];
    [_sortedUserSets removeAllObjects];
    NSMutableArray* sortedPids = [[NSMutableArray alloc] init];
    for(NSString* pid in pids){
        if(![_sortedUserSets containsObject:pid]){
            [_sortedUserSets addObject:pid];
            [sortedPids addObject:pid];
        }
    }
    
    EZDEBUG(@"Current QueryUser:%i, sortedPids:%i", _currentQueryUsers.count, _sortedUserSets.count);
    
    if(sortedPids.count){
        for(NSString* pid in sortedPids){
            EZPerson* ps = [_currentQueryUsers objectForKey:pid];
            if(ps){
                [res addObject:ps];
            }
        }
        successBlck(res);
    }else{
        [self getPhotoBooks:successBlck];
    }
    //return res;
    return nil;
}


- (void) loadPhotoBooks
{
    EZDEBUG(@"Will call the photo book");
    //NSError *error = nil;
    CFErrorRef error = nil;
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(NULL, &error);
    //ABAddressBookRef allPeople = ABAddressBookCreate()
    dispatch_async(_asyncQueue, ^(){
    
    ABAddressBookRequestAccessWithCompletion(allPeople,
                                             ^(bool granted, CFErrorRef error) {
                                                 CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
                                                 CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
                                                 
                                                 NSMutableArray* res = [[NSMutableArray alloc] init];
                                                 for(int i = 0; i < numberOfContacts; i++){
                                                     NSString* name = @"";
                                                     NSString* phone = @"";
                                                     NSString* email = @"";
                                                     
                                                     ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
                                                     ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
                                                     ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
                                                     
                                                     ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
                                                     ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
                                                     
                                                     NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
                                                     NSArray *phoneArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
                                                     
                                                     
                                                     if (lnameProperty != nil) {
                                                         name = [NSString stringWithFormat:@"%@", lnameProperty];
                                                     }
                                                     if (fnameProperty != nil) {
                                                         name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", fnameProperty]];
                                                     }
                                                     
                                                     if ([phoneArray count] > 0) {
                                                         if ([phoneArray count] > 1) {
                                                             for (int i = 0; i < [phoneArray count]; i++) {
                                                                 phone = [phone stringByAppendingString:[NSString stringWithFormat:@"%@\n", [phoneArray objectAtIndex:i]]];
                                                             }
                                                         }else {
                                                             phone = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:0]];
                                                         }
                                                     }
                                                     
                                                     if ([emailArray count] > 0) {
                                                         if ([emailArray count] > 1) {
                                                             for (int i = 0; i < [emailArray count]; i++) {
                                                                 email = [email stringByAppendingString:[NSString stringWithFormat:@"%@\n", [emailArray objectAtIndex:i]]];
                                                             }
                                                         }else {
                                                             email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
                                                         }
                                                     }
                                                     phone = phone.getIntegerStr;
                                                     //NSLog(@"NAME : %@",name);
                                                     //NSLog(@"PHONE: %@",phone);
                                                     //NSLog(@"EMAIL: %@",email);
                                                     //NSLog(@"\n");
                                                     EZPerson* person = [[EZPerson alloc] init];
                                                     person.name = name;
                                                     person.mobile = phone;
                                                     person.email = email;
                                                     //if(i % 2 == 0){
                                                     //    person.joined = true;
                                                     //    person.avatar = [EZFileUtil fileToURL:@"header_1.png"].absoluteString;
                                                         
                                                     //}else{
                                                     //    person.joined = false;
                                                     //    person.avatar = [EZFileUtil fileToURL:@"header_2.png"].absoluteString;
                                                         
                                                     //}
                                                     [res addObject:person];
                                                 }
                                                 
                                                 EZDEBUG(@"Completed photobook reading:%i", res.count);
                                                 //[[EZMessageCenter getInstance] postEvent:EZGetContacts attached:res];
                                                 [_contacts addObjectsFromArray:res];
                                                 
                                                 /**
                                                 EZEventBlock uploadBlock = ^(id obj){
                                                                                                     };
                                                 if(_currentPersonID){
                                                     uploadBlock(nil);
                                                 }else{
                                                     [[EZMessageCenter getInstance] registerEvent:EZUserAuthenticated block:uploadBlock];
                                                 }
                                                 **/

                                                 [[EZMessageCenter getInstance] postEvent:EZContactsReaded attached:res];
                                                });
    });
    //return res;
}


//- (void) uplo

//Read the Contacts list out
- (void) getPhotoBooks:(EZEventBlock)blk
{
    
    //NSError *error = nil;
    CFErrorRef error = nil;
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(NULL, &error);
    //ABAddressBookRef allPeople = ABAddressBookCreate()
    
    
    ABAddressBookRequestAccessWithCompletion(allPeople,
                                                 ^(bool granted, CFErrorRef error) {
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    NSLog(@"numberOfContacts------------------------------------%ld",numberOfContacts);
    
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(int i = 0; i < 2; i++){
        NSString* name = @"";
        NSString* phone = @"";
        NSString* email = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        NSArray *phoneArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        
        
        if (lnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", lnameProperty];
        }
        if (fnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", fnameProperty]];
        }
        
        if ([phoneArray count] > 0) {
            if ([phoneArray count] > 1) {
                for (int i = 0; i < [phoneArray count]; i++) {
                    phone = [phone stringByAppendingString:[NSString stringWithFormat:@"%@\n", [phoneArray objectAtIndex:i]]];
                }
            }else {
                phone = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:0]];
            }
        }
        
        if ([emailArray count] > 0) {
            if ([emailArray count] > 1) {
                for (int i = 0; i < [emailArray count]; i++) {
                    email = [email stringByAppendingString:[NSString stringWithFormat:@"%@\n", [emailArray objectAtIndex:i]]];
                }
            }else {
                email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
            }
        }
        phone = phone.getIntegerStr;
        //NSLog(@"NAME : %@",name);
        //NSLog(@"PHONE: %@",phone);
        //NSLog(@"EMAIL: %@",email);
        //NSLog(@"\n");
        EZPerson* person = [[EZPerson alloc] init];
        person.name = name;
        person.mobile = phone;
        person.email = email;
        [res addObject:person];
    }
                                                     
    EZDEBUG(@"Completed photobook reading, will call back now");
    if(blk){
        blk(res);
    }
                                                 });
    //return res;
}

//Dummy implementation now.
//Will change to read from the address book later.
- (void) getAllContacts:(EZEventBlock)blk
{
    [self getPhotoBooks:^(NSArray* persons){
        int i = 0;
        EZDEBUG(@"Get photoBook callback called:%i", persons.count);
    for(EZPerson* person in persons){
        //EZPerson* person = [[EZPerson alloc] init];
       
        /**
        person.personID =int2str(rand()%1000);
        //person.name = [NSString stringWithFormat:@"天哥:%i", i];
        person.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
        if(++i % 2 == 0){
            person.joined = true;
            person.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;

        }else{
            person.joined = false;
            person.avatar = [EZFileUtil fileToURL:@"img01.jpg"].absoluteString;

        }
         **/
        //[res addObject:person];
    }
        blk(persons);
    }];
}


//Should I give the person id or what?
//Let's give it. Expose the parameter make the function status free. More easier to debug
- (void) likedPhoto:(NSString*)combinePhotoID ownPhotoID:(NSString*)ownPhotoID like:(BOOL)like success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"combinePhotoID:%@", combinePhotoID);
    if(!self.currentPersonID){
        //Not login user.
        //
        [self triggerLogin:^(EZPerson* ps){
            [self rawLikePhoto:combinePhotoID ownPhotoID:ownPhotoID like:(BOOL)like success:success failure:failure];
        } failure:^(id obj){
            //failure(macroControlInfo(@""));
            [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"register-like-error") info:macroControlInfo(@"Please try it later")];
        } reason:macroControlInfo(@"register-like") isLogin:NO];
    }else{
        EZDEBUG(@"Will like directly");
        [self rawLikePhoto:combinePhotoID ownPhotoID:ownPhotoID like:like success:success failure:failure];
    }

}

//Will not trigger login.
- (void) rawLikePhoto:(NSString*)photoID ownPhotoID:(NSString*)ownPhotoID like:(BOOL)like success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:@{@"cmd":@"like", @"photoID":photoID, @"like":@(like), @"ownPhotoID":ownPhotoID} complete:^(id info){
        EZDEBUG(@"Like photo result:%@", info);
        if(success){
            success(info);
        }
    } failblk:^(id info){
        if(failure){
            EZDEBUG(@"Like photo error:%@", info);
            failure(info);
        }
    }];
    
}


- (void) prefetchImage:(NSString*) url success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    [_prefetchImage preloadImageURL:str2url(url) success:success failed:failure];
}

//Get the person object
- (EZPerson*) getPersonByID:(NSString*)personID success:(EZEventBlock)success;
{
    if(personID == nil){
        return nil;
    }
    EZPerson* ps = [_currentQueryUsers objectForKey:personID];
    if(!ps){
        //[self queryPendingPerson]
        ps = [[EZPerson alloc] init];
        ps.personID = personID;
        ps.isQuerying = true;
        [_currentQueryUsers setObject:ps forKey:personID];
    }
    if(ps.isQuerying){
        [_pendingUserQuery addObject:personID];
        NSMutableArray* queryCalls = [_pendingPersonCall objectForKey:personID];
        if(!queryCalls){
            queryCalls = [[NSMutableArray alloc] init];
            [_pendingPersonCall setObject:queryCalls forKey:personID];
        }
        if(success){
            [queryCalls addObject:success];
        }
        //Trigger the person query call
        [self queryPendingPerson];
    }else{
        if(success){
            success(ps);
        }
    }
    [self adjustActivity:ps.personID];
    return ps;
}

//Invite your friend
- (void) inviteFriend:(EZPerson*)person success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        success(nil);
    });
}

//Get converstaion regarding this photo
- (void) getConversation:(int)combineID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
   
}

//Will be used to adjust the squence.
- (void) adjustActivity:(NSString*)personID
{
    [_sortedUsers removeObject:personID];
    [_sortedUsers insertObject:personID atIndex:0];
}

//The converstation will add to the relationship.
- (void) addConverstaion:(int)combinedID text:(NSString*)text success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZConversation* cons = [[EZConversation alloc] init];
    //cons.speakerID = [self getCurrentPersonID];
    //cons.content = text;
    cons.text = text;
    dispatch_async(dispatch_get_main_queue(), ^(){
        success(cons);
    });
}

//The Photo object will returned.
//How about thumbnail.
//Should we generate it dynamically.
//Maybe we should.
//Photo here are serve as value object, carry value back and forth.

- (void) fetchImageFromAssetURL:(NSString*)url  success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    __block NSString* fileURL = [[EZImageFileCache getInstance] getImage:url];
    if(fileURL){
        success(fileURL);
        return;
    }
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        EZDEBUG(@"get image");
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            EZDEBUG(@"Really get it");
            UIImage* largeimage = [UIImage imageWithCGImage:iref];
            //[largeimage retain];
            fileURL = [[EZImageFileCache getInstance] storeImage:largeimage key:url];
            dispatch_async(dispatch_get_main_queue(), ^(){
                success(fileURL);
            });
            
        }else{
            EZDEBUG(@"Don't get it, what's wrong");
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
        if(failure){
            dispatch_async(dispatch_get_main_queue(), ^(){
                failure(myerror);
            });
        }
    };

    NSURL *asseturl = [NSURL URLWithString:url];
    if(_assetLibaray){
        _assetLibaray = [[ALAssetsLibrary alloc] init];
    }
    EZDEBUG(@"try to get image from:%@", url);
    dispatch_async(_asyncQueue, ^(){
        [_assetLibaray assetForURL:asseturl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    });
}


- (void) saveImage:(UIImage*)shotImage success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [_assetLibaray writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(shotImage) metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
     {
         if (error) {
             NSLog(@"ERROR: the image failed to be written");
             failure(error);
         }
         else {
             NSLog(@"PHOTO SAVED here - assetURL: %@", assetURL);
             [self assetURLToAsset:assetURL success:success];
         }
     }];
}

- (void) assetURLToAsset:(NSURL *)url success:(EZEventBlock)success
{
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        EZDEBUG(@"fetch asset success");
        success(myasset);
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        //NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        EZDEBUG(@"assets fetch error:%@", myerror);
    };
    
    //[NSURL *asseturl = [NSURL URLWithString:yourURL];
    //ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [_assetLibaray assetForURL:url
                    resultBlock:resultblock
                   failureBlock:failureblock];
}



//Will upload each pending photo
//Remove the photo from the array, once it is successfuls
//Should we differentitate uploaded information and uploaded file itself?
//Let's this method call on a time out fash.
- (void) addDeleteTask:(EZPhoto*)photo
{
    photo.deleted = TRUE;
    [_pendingUploads addObject:photo];
    /**
    if(photo.uploadPhotoSuccess){
        
    }else
    if(photo.uploadInfoSuccess){
        //[_pendingUploads addObject:photo];
        
    }
    **/
}


//Will be called before quit the game,
//So that next time I will continue what I am doing.
//This is just great.


- (void) storePendingPhoto
{
    for(int i = 0; i < _pendingPhotos.count; i++){
        EZPhoto* photo = [_pendingPhotos objectAtIndex:i];
        if(photo.isUploadDone){
            //[_pendingUploads removeObject:photo];
            continue;
        }
        
        LocalPhotos* lp = photo.localPhoto;
        if(lp){
            EZDEBUG(@"storePendingPhoto old objects");
        }else{
            lp = [[EZCoreAccessor getClientAccessor] create:[LocalPhotos class]];
            photo.localPhoto = lp;
        }
        EZDEBUG(@"storePendingPhoto is inserted:%i", lp.isInserted);
        lp.payloads = [photo toLocalJson].mutableCopy;
        lp.photoID = photo.photoID;
        lp.createdTime = photo.createdTime;
    }
    //[[EZCoreAccessor getClientAccessor] saveContext];
}

- (void) uploadPendingPhoto
{
    if(_pauseUpload){
        EZDEBUG(@"Quit for uploading pause");
        return;
    }
    if(_uploadingTasks > 0){
        EZDEBUG(@"Quit for uploading, pending Task:%i", _uploadingTasks);
        return;
    }
    
    
    EZDEBUG(@"The uploadTasks is:%i", _pendingUploads.count);
    NSArray* uploads = [[NSArray alloc] initWithArray:_pendingUploads];
    for(int i = 0; i < uploads.count; i++){
        
        EZPhoto* photo = [uploads objectAtIndex:i];
        if(photo.deleted){
            if(photo.photoID){
                ++ _uploadingTasks;
                EZDEBUG(@"Will delete:%@", photo.photoID);
                [self deletePhoto:photo success:^(id info){
                    EZDEBUG(@"deleted success");
                    [_pendingUploads removeObject:photo];
                    -- _uploadingTasks;
                    
                } failure:^(id err){
                    EZDEBUG(@"failed to delete");
                    -- _uploadingTasks;
                }];
            }else{
                EZDEBUG(@"need to delete a photo without id");
                [_pendingUploads removeObject:photo];
            }
            continue;
        }
        
        if(photo.isUploadDone){
            EZDEBUG(@"Remove photo when upload is done:%i, screenURL:%@", photo.updateStatus, photo.screenURL);
            photo.type = 0;
            [_pendingUploads removeObject:photo];
            [self storeAllPhotos:@[photo]];
            continue;
        }
        
        //if(photo.assetURL == nil || [photo.assetURL isEmpty] || [EZFileUtil isFileExist:photo.assetURL isURL:YES]){
        //    EZDEBUG(@"Remove assetURL is nil");
        //    [_pendingUploads removeObject:photo];
        //}
        
        
        EZDEBUG(@"upload status:%i, updateStatus:%i, infoStatus:%i, exchangeStatus:%i", photo.contentStatus, photo.updateStatus, photo.infoStatus, photo.exchangeStatus);
        
        EZEventBlock exchangeContent = ^(EZPhoto* photo){
             EZDEBUG(@"Will invoke exchange photo, status:%i, personID:%@, exchangeID:%@", photo.exchangeStatus, photo.personID, photo.exchangePersonID);
            if(photo.exchangeStatus == kExchangeStart || photo.exchangeStatus == kExchangeFailure){
                ++_uploadingTasks;
                photo.exchangeStatus = kExchangeStart;
           
                [self exchangeWithPerson:photo.exchangePersonID photoID:photo.photoID success:^(EZPhoto* ph){
                EZDEBUG(@"exchange success with:%@", ph.photoID);
                photo.photoRelations = @[ph];
                photo.exchangeStatus = kExchangeDone;
                
                //if(photo.conversations.count && !photo.conversationUploaded){
                //    photo.uploadStatus = kUpdateConversation;
                //}
                if(photo.uploadSuccess){
                    photo.uploadSuccess(photo);
                }
                photo.uploadSuccess = nil;
                --_uploadingTasks;
            } failure:^(id err){
                EZDEBUG(@"Failed to find match photo:%@", err);
                photo.exchangeStatus = kExchangeFailure;
                --_uploadingTasks;
            }];
            }
        };
        
        
        
        EZEventBlock uploadContent = ^(EZPhoto* photo){
            if(photo.contentStatus == kUploadInit){
                ++_uploadingTasks;
                EZDEBUG(@"Will start upload photo content for:%@", photo.photoID);
                [[EZDataUtil getInstance] uploadPhoto:photo success:^(id info){
                    EZDEBUG(@"uploaded content success:%@, photoRelations:%i", info, photo.photoRelations.count);
                    //photo.uploadStatus = kExchangePhoto;
                    photo.contentStatus = kUploadDone;
                    photo.uploaded = TRUE;
                    photo.progress = nil;
                    --_uploadingTasks;
                    if(photo.photoRelations.count){
                        //photo.uploadStatus = kUploadDone;
                        if(photo.uploadSuccess){
                            photo.uploadSuccess(photo);
                        }
                        photo.uploadSuccess = nil;
                    }else{
                        photo.exchangeStatus = kExchangeStart;
                        exchangeContent(photo);
                    }
                    
                } failure:^(id err){
                    EZDEBUG(@"failed to upload content:%@", err);
                    --_uploadingTasks;
                    if(photo.progress){
                        photo.progress(nil);
                    }
                }];
            }

        
        };
        
        
        EZEventBlock uploadInfo = ^(EZPhoto* photo){
            EZDEBUG(@"Will start upload info for:%@", photo.photoID);
            ++_uploadingTasks;
            //bool haveConversation = photo.conversations.count;
            [[EZDataUtil getInstance] uploadPhotoInfo:@[photo] success:^(id info){
                EZDEBUG(@"Update photo info:%@", info);
                NSString* photoID = [info objectAtIndex:0];
                //photo.conversationUploaded = haveConversation;
                EZDEBUG(@"Recieved photoID:%@, currnet photoID:%@", photoID, photo.photoID);
                photo.infoStatus = kUploadDone;
                photo.photoID = photoID;
                --_uploadingTasks;
                uploadContent(photo);
            } failure:^(id err){
                EZDEBUG(@"failed to upload info for photoID:%@, :%@",photo.photoID, err);
                --_uploadingTasks;
                if(photo.progress){
                    photo.progress(nil);
                }
            }];
            
        };
        EZEventBlock updateInfo = ^(EZPhoto* photo){
            EZDEBUG(@"Will start update info for:%@", photo.photoID);
            if(!photo.photoID || [photo.photoID isEmpty]){
                EZDEBUG(@"Quit for not have photoID, to avoid have multiple photo ID");
                return;
            }
            ++_uploadingTasks;
                        //bool haveConversation = photo.conversations.count;
            [[EZDataUtil getInstance] uploadPhotoInfo:@[photo] success:^(id info){
                EZDEBUG(@"Update photo info:%@", info);
                NSString* photoID = [info objectAtIndex:0];
                //photo.conversationUploaded = haveConversation;
                EZDEBUG(@"Recieved photoID:%@, currnet photoID:%@", photoID, photo.photoID);
                photo.updateStatus = kUpdateDone;
                photo.photoID = photoID;
                --_uploadingTasks;
                //uploadContent(photo);
            } failure:^(id err){
                EZDEBUG(@"failed to upload info for photoID:%@, :%@",photo.photoID, err);
                --_uploadingTasks;
                if(photo.progress){
                    photo.progress(nil);
                }
            }];
            
        };
        if(photo.infoStatus == kUploadInit){
            uploadInfo(photo);
        }else if(photo.exchangeStatus == kExchangeFailure || photo.exchangeStatus == kExchangeStart){
            exchangeContent(photo);
        }else if(photo.updateStatus == kUpdateStart){
            updateInfo(photo);
        }else if(photo.contentStatus == kUploadInit){
            uploadContent(photo);
        }
    }
}

- (void) uploadPhoto:(EZPhoto*) photo
{
    [[EZDataUtil getInstance] uploadPhotoInfo:@[photo] success:^(id info){
        EZDEBUG(@"Update photo info:%@", info);
    } failure:^(id err){
        EZDEBUG(@"failed to upload info for photoID:%@, :%@",photo.photoID, err);
    }];
    
    [[EZDataUtil getInstance] uploadPhoto:photo success:^(id info){
        EZDEBUG(@"uploaded success:%@", info);
    } failure:^(id err){
        EZDEBUG(@"failed to upload content:%@", err);
    }];
    
}

- (void) checkPhotoAlbum:(EZEventBlock)success failure:(EZEventBlock)failure
{
    

}

//Read all the photos stored in the local database
- (NSArray*) getStoredPhotos
{
    NSArray* photos = [[EZCoreAccessor getClientAccessor] fetchAll:[LocalPhotos class] sortField:@"createdTime" ascending:NO];
    NSMutableArray* res = [[NSMutableArray alloc] init];
    EZDEBUG(@"Stored photos count:%i", photos.count);
    for(LocalPhotos* photo in photos){
        //LocalPhotos* lp = [[EZCoreAccessor getClientAccessor] create:[LocalPhotos class]];
        //if([photo.payloads isKindOfClass:[NSDictionary class]]){
            EZPhoto* ph = [[EZPhoto alloc] init];
            [ph fromLocalJson:photo.payloads];
            ph.localPhoto = photo;
            [res addObject:ph];
        if(!ph.isUploadDone){
            EZDEBUG(@"will add photo into pending upload:%@, relations:%i", ph.photoID, ph.photoRelations.count);
            [self.pendingUploads addObject:ph];
        }
    }
    return res;
}

- (void) storeAll
{
    [self storeAllPhotos:_currentPhotos];
}

- (void) storeAllPhotos:(NSArray*)photos
{
    for(EZPhoto* ph in photos){
        LocalPhotos* lp = ph.localPhoto;
        if(lp){
            EZDEBUG(@"store old objects");
        }else{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoID = %@", ph.photoID];
            NSArray* existPhoto = [[EZCoreAccessor getClientAccessor] fetchObject:[LocalPhotos class] byPredicate:predicate withSortField:Nil ascending:NO];
            EZDEBUG(@"Query ID in db:%@,query count:%i", ph.photoID, existPhoto.count);
            if(existPhoto.count){
                lp = [existPhoto objectAtIndex:0];
            }else{
                lp = [[EZCoreAccessor getClientAccessor] create:[LocalPhotos class]];
            }
            ph.localPhoto = lp;
        }
        EZDEBUG(@"is inserted:%i", lp.isInserted);
        lp.payloads = [ph toLocalJson].mutableCopy;
        lp.photoID = ph.photoID;
        lp.createdTime = ph.createdTime;
        
        
    }
    [[EZCoreAccessor getClientAccessor] saveContext];
}


- (void) addPendingUpload:(EZPhoto*)photo
{
    if(![_pendingPhotos containsObject:photo]){
        [_pendingPhotos addObject:photo];
    }
}

- (void) storeAllPersons:(NSArray*)persons
{
    for(EZPerson* ps in persons){
        ps.uploaded = true;
        LocalPersons* lp = ps.localPerson;
        if(lp){
            EZDEBUG(@"store old persons %@, json:%@", ps.localPerson, [ps toJson]);
            lp.payloads = [ps toJson];
        }else{
            lp = [[EZCoreAccessor getClientAccessor] create:[LocalPersons class]];
            ps.localPerson = lp;
            lp.personID = ps.personID;
            lp.lastActive = ps.lastActive;
            lp.mobile = ps.mobile;
            lp.payloads = [ps toJson];
        }
        lp.uploaded = @(ps.uploaded);
    }
    [[EZCoreAccessor getClientAccessor] saveContext];
}

//Check if all the photo stored.
- (void) checkAndUpload:(NSArray*)persons
{
    NSMutableDictionary* storedPerson = [self getStoredPersons];
    //NSMutableDictionary* pendingUploadPerson = [[NSMutableDictionary alloc] initWithDictionary:storedPerson];
    NSMutableArray* uploadPersons = [[NSMutableArray alloc] init];
    for(EZPerson* ps in persons){
        EZPerson* ep = [storedPerson objectForKey:ps.mobile];
        
        if(ep){
            if(!ep.localPerson.uploaded.intValue){
                [uploadPersons addObject:ep];
                //[pendingUploadPerson setObject:ep forKey:ep.mobile];
            }
        }else{
            [uploadPersons addObject:ps];
            //[pendingUploadPerson setObject:ps forKey:ps.mobile];
        }
        //if(ps.joined){
        // [_sortedUsers addObject:ps];
        //}
    }
    EZDEBUG(@"final upload:%i, total:%i, joined:%i, storedPerson:%i", uploadPersons.count, persons.count, _sortedUsers.count, storedPerson.count);
    [self uploadContacts:uploadPersons success:^(NSArray* arr){
        [self storeAllPersons:arr];
    } failure:^(id err){
        EZDEBUG(@"Upload person failure:%@", err);
    }];
}

- (NSArray*) getStoredPersonLists
{
   
    NSMutableArray* res = [[NSMutableArray alloc] init];
    //NSMutableArray* addedUser = [[NSMutableArray alloc] init];
    NSMutableSet* stored = [[NSMutableSet alloc] init];
    //EZPerson* currentUser = nil;
    for(NSString* pid in _sortedUsers){
        EZPerson* ps = [_currentQueryUsers objectForKey:pid];
        if(![stored containsObject:pid]){
            if(![pid isEqualToString:currentLoginID]){
                [res addObject:ps];
            }
        }
    }
    //[addedUser addObjectsFromArray:res];
    [res insertObject:currentLoginUser atIndex:0];
    return res;
}



- (NSArray*) getStoredPersonListsOld
{
    NSArray* persons = [[EZCoreAccessor getClientAccessor] fetchAll:[LocalPersons class] sortField:@"lastActive" ascending:NO];
    NSMutableArray* res = [[NSMutableArray alloc] init];
    NSMutableArray* addedUser = [[NSMutableArray alloc] init];
    EZPerson* currentUser = nil;
    for(LocalPersons* lp in persons){
        EZPerson* ps = [[EZPerson alloc] init];
        [ps fromJson:lp.payloads];
        ps.localPerson = lp;
        ps.uploaded = lp.uploaded.integerValue;
        if(ps.joined){
            //[_sortedUsers addObject:lp.personID];
            if(![currentUser.personID isEqualToString:currentLoginID]){
                [addedUser addObject:ps];
            }
        }else{
            [res addObject:ps];
        }
        //[res addObject:ps];
    }
    [addedUser addObjectsFromArray:res];
    [addedUser insertObject:currentLoginUser atIndex:0];
    return addedUser;
}



- (void) reloadAllStoredPersons
{
    NSArray* persons = [[EZCoreAccessor getClientAccessor] fetchAll:[LocalPersons class] sortField:@"lastActive" ascending:NO];
    EZDEBUG(@"All stored persons:%i", persons.count);
    for(LocalPersons* lp in persons){
        EZPerson* ps = [[EZPerson alloc] init];
        [ps fromJson:lp.payloads];
        ps.localPerson = lp;
        ps.uploaded = lp.uploaded.integerValue;
        if(ps.joined){
            [_sortedUsers addObject:lp.personID];
        }
        if(ps.mobile){
            //[res setObject:ps forKey:ps.mobile];
        }
        if([ps.personID isNotEmpty]){
            [_currentQueryUsers setObject:ps forKey:ps.personID];
        }
    }
    //return res;
}
//Read all the stored person out
- (NSMutableDictionary*) getStoredPersons
{
    
    NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
    NSArray* persons = [[EZCoreAccessor getClientAccessor] fetchAll:[LocalPersons class] sortField:@"lastActive" ascending:NO];
    EZDEBUG(@"All stored persons:%i", persons.count);
    for(LocalPersons* lp in persons){
        EZPerson* ps = [[EZPerson alloc] init];
        [ps fromJson:lp.payloads];
        ps.localPerson = lp;
        ps.uploaded = lp.uploaded.integerValue;
        if(ps.joined){
            [_sortedUsers addObject:lp.personID];
        }
        if(ps.mobile){
            [res setObject:ps forKey:ps.mobile];
        }
        if([ps.personID isNotEmpty]){
            [_currentQueryUsers setObject:ps forKey:ps.personID];
        }
    }
    return res;
}

- (void) loadAllPersons
{
    NSArray* persons = [[EZCoreAccessor getClientAccessor] fetchAll:[LocalPersons class] sortField:nil ascending:NO];
    //NSMutableArray* res = [[NSMutableArray alloc] init];
    EZDEBUG(@"stored person count:%i", persons.count);
    for(LocalPersons* ps in persons){
        //LocalPhotos* lp = [[EZCoreAccessor getClientAccessor] create:[LocalPhotos class]];
        //if([photo.payloads isKindOfClass:[NSDictionary class]]){
        EZPerson* ph = [[EZPerson alloc] init];
        [ph fromJson:ps.payloads];
        ph.localPerson = ps;
        //[res addObject:ph];
        [_currentQueryUsers setObject:ph forKey:ph.personID];
    }
    //return res;

}



@end
