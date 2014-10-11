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
#import "EZExtender.h"
#import "EZSoundEffect.h"
#import "EZClickView.h"
#import "EZFileUtil.h"
//#import "EZHomeBlendFilter.h"
#import "EZNetworkUtility.h"
//#import <GPUImageFilter.h>
#import "EZShotTask.h"
#import "EZStoredPhoto.h"


@interface EZHolder : NSObject

@property (nonatomic, strong) NSMapTable* mapTable;
@property (nonatomic, strong) NSMapTable* mapTable2;
@property (nonatomic, strong) NSMutableDictionary* mapTable3;

SINGLETON_FOR_HEADER(EZHolder);

@end

@implementation EZHolder

- (id) init
{
    self = [super init];
    _mapTable = [NSMapTable strongToWeakObjectsMapTable];
    _mapTable2 = [NSMapTable weakToStrongObjectsMapTable];
    _mapTable3 = [[NSMutableDictionary alloc] init];
    return self;
}

SINGLETON_FOR_CLASS(EZHolder);

@end


@interface WeakHolder : NSObject

@property (nonatomic, weak) id obj;

- (id) init:(id)obj;
@end

@implementation WeakHolder

- (id) init:(id)obj
{
    self = [super init];
    _obj = obj;
    return self;
}

@end

@interface ReleasedObj : NSObject


@property (nonatomic, strong) NSString* name;

@end

@implementation ReleasedObj

- (void) dealloc
{
    EZDEBUG(@"Dealloced release:%@", _name);
    if([@"re1" isEqualToString:_name]){
        EZDEBUG(@"re1's map value is:%@",[EZHolder.sharedEZHolder.mapTable objectForKey:@"re1"]);
    }
}

@end



@implementation EZTestSuites

+ (void) testAll
{
    
    //[EZTestSuites testImageCache];
    //assert(false);
    //[EZTestSuites testAssetFetch];
    //[EZTestSuites testAddressBook];
    //[EZTestSuites testGetNumberFromString];
    //[EZTestSuites testSoundEffects];
    //[self testImageProcess];
    //[self testImageStore];
    //[self testIndexOfObject];
    //[self testFileNameChange];
    //[self testFullFetchBack];
    //[self testUploadTask];
    //NSInteger val = 1;
    //EZDEBUG(@"the hash is:%i, %i", @"xxoo1".hash, [NSString stringWithFormat:@"xxoo%i", val].hash);
    //NSInteger hashed = [NSString stringWithFormat:@"xxoo%i", val].hash;
    //EZDEBUG(@"final hashed:%i", hashed);
    //assert( @"xxoo1".hash == hashed);
    //[self testReplaceURLHost];
    
    /**
    int val1 = ~255;
    int val2 = 2 & ~255;
    int val3 = 3 & ~255;
    int final = ~255 & ~255;
    
    EZDEBUG(@"val1:%i, val2:%i, val3:%i, final:%i", val1, val2, val3, final);
    assert(false);
     **/
    [self testWeakMaps];
    
    EZDEBUG(@"re1:%@, re2:%@", [[EZHolder sharedEZHolder].mapTable objectForKey:@"re1"],[[EZHolder sharedEZHolder].mapTable objectForKey:@"re2"]);
    //assert(false);
}


+ (void) testWeakMaps
{
    EZHolder* holder = [EZHolder sharedEZHolder];
    ReleasedObj* re1 = [[ReleasedObj alloc] init];
    ReleasedObj* re2 = [[ReleasedObj alloc] init];
    ReleasedObj* re3 = [[ReleasedObj alloc] init];
    ReleasedObj* re4 = [[ReleasedObj alloc] init];
    re1.name = @"re1";
    re2.name = @"re2";
    re3.name = @"re3";
    re4.name = @"re4";
    [holder.mapTable setObject:re1 forKey:@"re1"];
    [holder.mapTable2 setObject:re2 forKey:@"re2"];
    [holder.mapTable3 setObject:[[WeakHolder alloc] init:re4] forKey:@"re4"];
    
    EZDEBUG("value is:%@", [holder.mapTable objectForKey:@"re1"]);
    EZDEBUG(@"value2 is:%@", [holder.mapTable2 objectForKey:@"re2"]);
    re1=nil;
    re2=nil;
    re3=nil;
    re4=nil;
    EZDEBUG("value is:%@", [holder.mapTable objectForKey:@"re1"]);
    EZDEBUG(@"value2 is:%@", [holder.mapTable objectForKey:@"re2"]);
    //assert(false);
}

+ (void) testReplaceURLHost
{
    //NSString* host = @"http://coolgguy/xxoo";
    NSURL* url = [NSURL URLWithString:@"http://coolgguy/xxoo"];
    NSString* host = [url host];
    NSString* path = [url path];
    NSString* baseURL = [url relativePath];
    EZDEBUG(@"host:%@, path:%@, baseURL:%@", host, path, baseURL);
    assert(false);
}

+ (void) testUploadTask
{
    [[EZDataUtil getInstance] createTaskID:^(NSString* taskID){
        EZDEBUG(@"The taskID is:%@", taskID);
        //NSMutableArray* storedPhoto = [[NSMutableArray alloc] init];
        EZShotTask* task = [[EZShotTask alloc] init];
        task.taskID = taskID;
        EZStoredPhoto* photo = [[EZStoredPhoto alloc] init];
        photo.taskID = taskID;
        photo.localFileURL = [EZFileUtil bundleToURL:@"tiange.jpg" retinaAware:NO];
        photo.sequence = 2;
        /**
        [[EZDataUtil getInstance] uploadStoredPhoto:photo success:^(EZStoredPhoto* ph){
            EZDEBUG(@"The returned photoID:%@, remoteURL:%@", ph.photoID,ph.remoteURL);
            [task.photos addObject:ph];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        **/
        
        
        
        EZStoredPhoto* photo2 = [[EZStoredPhoto alloc] init];
        photo2.taskID = taskID;
        photo2.localFileURL = [EZFileUtil bundleToURL:@"wall.jpg" retinaAware:NO];
        photo2.sequence = 3;
        
        /**
        [[EZDataUtil getInstance] uploadStoredPhoto:photo2 success:^(EZStoredPhoto* ph){
            EZDEBUG(@"The second returned photoID:%@, remoteURL:%@", ph.photoID,ph.remoteURL);
            [task.photos addObject:ph];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        **/
        dispatch_later(1.0, ^(){
            //EZShotTask* task =
            EZDEBUG(@"before sequence adjust:%@, count:%i", task.taskID, task.photos.count);
            [task.photos removeObject:photo];
            [task.photos addObject:photo];
            [[EZDataUtil getInstance] updateTaskSequence:task success:^(id obj){
                EZDEBUG(@"change sequence success, query task back:%@", taskID);
                [[EZDataUtil getInstance] queryByTaskID:taskID success:^(EZShotTask* tk){
                    EZDEBUG(@"query photo back:%@, photo count:%i", tk.taskID, tk.photos.count);
                    for(EZStoredPhoto* sp in tk.photos){
                        EZDEBUG(@"new sequence id:%@", sp.photoID);
                    }
                    
                } failure:^(id err){}];
            } failure:^(id err){}];
        });
        
    } failure:^(id err){
        EZDEBUG(@"error:%@", err);
    }];
}

+ (void) testFullFetchBack
{
    [[EZDataUtil getInstance] queryInitialSettings:nil failure:nil];
}

+ (void) testFileNameChange
{
    NSString* existDot = @"/cool/coolguy.png";

    NSString* notExistDot = @"/cool/hotgirlhaha";
    NSRange header = [existDot rangeOfString:@"." options:NSBackwardsSearch];
   
    NSRange notHeader = [notExistDot rangeOfString:@"." options:NSBackwardsSearch];
    
    NSString* resultStr = [EZFileUtil bundleToURL:existDot retinaAware:YES];
    NSString* nextResult = [EZFileUtil bundleToURL:notExistDot retinaAware:YES];
    EZDEBUG(@"header location:%i, notHeader:%i, resultStr:%@, %@", header.location, notHeader.location, resultStr, nextResult);
    assert(false);
    /**
    if(header.location < org.length){
        NSString* prev = [org substringToIndex:header.location];
        NSString* combined = [prev stringByAppendingPathExtension:replace];
        return combined;
    }else {
        return [org stringByAppendingPathExtension:replace];
    }
    **/
    
}

+ (void) testIndexOfObject
{
    NSArray* objects = @[@"1",@"2",@"3"];
    NSInteger obj1Pos = [objects indexOfObject:@"1"];
    NSInteger objNone = [objects indexOfObject:@"4"];
    EZDEBUG(@"obj1Pos:%i, none:%i, notFound:%i", obj1Pos, objNone, objNone == NSNotFound);
    //assert(false);
}

+ (void) testPersonQuery
{
    ReleasedObj* obj = [[ReleasedObj alloc] init];
    obj.name = @"Tian";
    [[EZDataUtil getInstance] uploadAvatar:[UIImage imageNamed:@"header_1"] success:^(NSString* url){
        EZDEBUG(@"Final url is:%@", url);
    } failure:^(id err){
        EZDEBUG(@"error:%@", err);
    }];
    
    [[EZDataUtil getInstance] getPersonByID:@"52f78923e7b5b9dd9c28f1ce" success:^(EZPerson* ps){
        EZDEBUG(@"Query back person id:%@, isQuerying:%i, name:%@, releaseName:%@", ps.personID, ps.isQuerying, ps.name, obj.name);
    }];
    
    [[EZDataUtil getInstance] getPersonByID:@"52f78b93e7b5b9dd9c28f1d1" success:^(EZPerson* ps){
        EZDEBUG(@"Query back person id:%@, isQuerying:%i, name:%@", ps.personID, ps.isQuerying, ps.name);
    }];
    
    [[EZDataUtil getInstance] getPersonByID:@"52f78923e7b5b9dd9c28f1ce" success:^(EZPerson* ps){
        EZDEBUG(@"Second Query back person id:%@, isQuerying:%i, name:%@", ps.personID, ps.isQuerying, ps.name);
    }];
    
    [[EZDataUtil getInstance] getPersonByID:@"52f78b93e7b5b9dd9c28f1d1" success:^(EZPerson* ps){
        EZDEBUG(@"Second Query back person id:%@, isQuerying:%i, name:%@", ps.personID, ps.isQuerying, ps.name);
    }];

}

+ (void) testImageStore
{
    UIImage* testImg = [UIImage imageNamed:@"smile_face.png"];
    NSString* storedFile = [EZFileUtil saveImageToDocument:testImg];
    UIImage* readBack = [UIImage imageWithContentsOfFile:storedFile];
    EZDEBUG(@"storedFile:%@, org size:%@, stored size:%@", storedFile, NSStringFromCGSize(testImg.size), NSStringFromCGSize(readBack.size));
}

+ (void) testImageProcess
{
   
}

+ (void) testClickView:(UIView *)parentView
{
    EZClickView* longPress = [[EZClickView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    longPress.backgroundColor = RGBCOLOR(255, 128, 70);
    [longPress recieveLongPress:1.0 callback:^(EZClickView* view){
        EZDEBUG(@"Long pressed get called");
        view.backgroundColor = randBack(nil);
    }];
    
    longPress.releasedBlock = ^(id obj){
        EZDEBUG(@"Long press click get called");
    };
    
    [parentView addSubview:longPress];
}

+ (void) testAlphaSetting:(UIView*)view
{
    UIView* alphaFull = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    alphaFull.backgroundColor = [UIColor redColor];
    alphaFull.alpha = 1.0;
    
    UIView* alphaZero = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    alphaZero.backgroundColor= [UIColor greenColor];
    alphaZero.alpha = 0.0;
    
    [view addSubview:alphaFull];
    [view addSubview:alphaZero];
}

+ (UIView*) testResizeMasks
{
    EZClickView* parentView = [[EZClickView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    parentView.backgroundColor = RGBCOLOR(255, 128, 0);
    
    
    EZClickView* childView = [[EZClickView alloc] initWithFrame:CGRectMake(50, 60, 100, 100)];
    ;
    childView.backgroundColor = RGBCOLOR(0, 255, 128);
    childView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [parentView addSubview:childView];
    //[self.tableView addSubview:parentView];
    __weak UIView* obj = parentView;
    childView.releasedBlock = ^(id inside){
        
        EZDEBUG(@"The release block get called, child size:%@, parent auto resize:%i", NSStringFromCGRect(childView.frame), parentView.autoresizesSubviews);
        [UIView animateWithDuration:1 animations:
         ^(){
             
             if(obj.frame.size.height == 200){
                 [obj setSize:CGSizeMake(200, 350)];
             }else{
                 [obj setSize:CGSizeMake(200, 200)];
             }
         }
         ];
    };
    return parentView;

}

+ (void) testSoundEffects
{
    EZSoundEffect* sf = [[EZSoundEffect alloc] initWithSoundNamed:@"page_turn.aiff"];
    [sf play];
}

+ (void) testGetNumberFromString
{
    EZDEBUG(@"Get the number from string");
    NSString* number1 = @"haha123-456-789aab";
    NSString* fetched = [number1 getIntegerStr];
    EZDEBUG(@"The integer is:%@", fetched);
    
    NSString* number2 = @"987-654-321hehehe";
    NSString* integer2 = [number2 getIntegerStr];
    EZDEBUG(@"The second integer is:%@", integer2);
    
}

+ (void) testAddressBook
{
    [[EZDataUtil getInstance] getPhotoBooks:^(NSArray* books){
        EZDEBUG(@"The total fetched persons:%i", books.count);
    }];
    
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
