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
#import "EZRegisterController.h"
#import "EZCenterButton.h"


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
    //Move to the persistent later.
    //Now keep it simple and stupid
    _pendingUploads = [[NSMutableArray alloc] init];
    _prefetchImage = [[UIImageView alloc] init];
    _pendingUserQuery = [[NSMutableSet alloc] init];
    _currentQueryUsers = [[NSMutableDictionary alloc] init];
    _pendingPersonCall = [[NSMutableDictionary alloc] init];
    _timeFormatter = [[NSDateFormatter alloc] init];
    
    _totalCover = [[EZClickView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _totalCover.enableTouchEffects = false;
    _totalCover.backgroundColor = [UIColor clearColor];
    [_timeFormatter setDateStyle:NSDateFormatterShortStyle];
    [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_timeFormatter setDoesRelativeDateFormatting:YES];
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
        EZDEBUG(@"successfully query:%i users back", dupIDs.count);
        for(NSDictionary* pdict in arr){
            EZPerson* ps = [self addPersonToStore:pdict isQuerying:NO];
            //[_currentQueryUsers setValue:ps forKey:ps.personID];
            [_pendingUserQuery removeObject:ps.personID];
            [self callPendingQuery:ps];
        }
        _queryingCount = false;
    } failure:^(id obj){
        EZDEBUG(@"failed to do the jobs");
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
        [ps fromJson:dict];
        EZDEBUG(@"jointed time :%@", ps.joinedTime);
    }
}

- (void) uploadContacts:(NSArray*)contacts success:(EZEventBlock)succss failure:(EZEventBlock)failure
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for(EZPerson* ps in contacts){
        [arr addObject:[ps toJson]];
    }
    [EZNetworkUtility postJson:@"person/info" parameters:arr complete:^(NSArray* array){
        [self populatePersons:array persons:contacts];
        succss(array);
    } failblk:^(id err){
        EZDEBUG(@"error:%@", err);
    }];
}

- (void) registerUser:(NSDictionary*)person success:(EZEventBlock)success error:(EZEventBlock)error
{
    [EZNetworkUtility postJson:@"register" parameters:person complete:^(NSDictionary* dict){
        EZPerson* person = [self addPersonToStore:dict isQuerying:NO];
        self.currentPersonID  = person.personID;
        self.currentLoginPerson = person;
        EZDEBUG(@"Returned person id:%@", person.personID);
        success(person);
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
- (void) queryPhotos:(int)page pageSize:(int)pageSize  success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:@{@"cmd":@"query",
                                                         @"startPage":@(page),
                                                         @"pageSize":@(pageSize)
                                                         }
                     complete:^(NSArray* photos){
                         EZDEBUG(@"Photo size:%i",photos.count);
                         NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:photos.count];
                         for(NSDictionary* dict in photos){
                             EZPhoto* photo = [[EZPhoto alloc] init];
                             [photo fromJson:dict];
                             if(photo.size.width > 0){
                                 [res addObject:photo];
                             }else{
                                 EZDEBUG(@"Photo is broken:%@", photo.photoID);
                             }
                         }
                         if(success){
                             success(res);
                         }
    
    } failblk:failure];
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
- (void) uploadPhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    //NSDictionary* jsonInfo = [photo toJson];
    NSString* storedFile =[EZFileUtil saveImageToCache:[photo getScreenImage]];
    if(photo.photoID){
        [EZNetworkUtility upload:baseUploadURL parameters:@{@"photoID":photo.photoID} file:storedFile complete:^(id obj){
            NSString* screenURL = [obj objectForKey:@"screenURL"];
            photo.screenURL = screenURL;
            photo.uploaded = TRUE;
            EZDEBUG(@"uploaded screenURL:%@", screenURL);
            success(photo);
        } error:failure progress:^(CGFloat percent){
            EZDEBUG(@"The uploaded percent:%f", percent);
        }];
    }else{
        EZDEBUG(@"photo have no id, waiting for id");
        failure(@"Need id to upload");
    }
}

//What's the purpose of this
//Whether we allow the login page to show off or not.
//Why do we ask them to register
//Login or register can 
- (void) triggerLogin:(EZEventBlock)success failure:(EZEventBlock)failure reason:(NSString*)reason isLogin:(BOOL)isLogin
{
    
    EZRegisterController* registerCtl = [[EZRegisterController alloc] init];
    registerCtl.registerReason.text = reason;
    registerCtl.completedBlock = ^(id obj){
        //_centerButton.hidden = NO;
        if(success){
            success(obj);
        }
    };
    registerCtl.cancelBlock = ^(id obj){
        //_centerButton.hidden = NO;
        if(failure){
            failure(obj);
        }
    };
    
    registerCtl.dismissBlock = ^(id obj){
        _centerButton.hidden = NO;
    };
    
    UIViewController* presenter = [EZUIUtility topMostController];
    [presenter presentViewController:registerCtl animated:YES completion:^(){
        _centerButton.hidden = YES;
    }];
    
}


- (void) loginUser:(NSDictionary*)loginInfo success:(EZEventBlock)success error:(EZEventBlock)error
{
    [EZNetworkUtility postJson:@"login" parameters:loginInfo complete:^(NSDictionary* dict){
        EZPerson* person = [[EZPerson alloc] init];
        [person fromJson:dict];
        self.currentPersonID = person.personID;
        self.currentLoginPerson = person;
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
                                                     if(i % 2 == 0){
                                                         person.joined = true;
                                                         person.avatar = [EZFileUtil fileToURL:@"header_1.png"].absoluteString;
                                                         
                                                     }else{
                                                         person.joined = false;
                                                         person.avatar = [EZFileUtil fileToURL:@"header_2.png"].absoluteString;
                                                         
                                                     }
                                                     [res addObject:person];
                                                 }
                                                 
                                                 EZDEBUG(@"Completed photobook reading, will call back now");
                                                 [[EZMessageCenter getInstance] postEvent:EZGetContacts attached:res];
                                                 [_contacts addObjectsFromArray:res];
                                                });
    });
    //return res;
}


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
        //[res addObject:person];
    }
        blk(persons);
    }];
}


//Should I give the person id or what?
//Let's give it. Expose the parameter make the function status free. More easier to debug
- (void) likedPhoto:(NSString*)combinePhotoID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"combinePhotoID:%@", combinePhotoID);
    if(!self.currentPersonID){
        //Not login user.
        //
        [self triggerLogin:^(EZPerson* ps){
            [self rawLikePhoto:combinePhotoID success:success failure:failure];
        } failure:^(id obj){
            //failure(macroControlInfo(@""));
            [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"register-like-error") info:macroControlInfo(@"Please try it later")];
        } reason:macroControlInfo(@"register-like") isLogin:NO];
    }else{
        EZDEBUG(@"Will like directly");
        [self rawLikePhoto:combinePhotoID success:success failure:failure];
    }

}

//Will not trigger login.
- (void) rawLikePhoto:(NSString*)photoID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    [EZNetworkUtility postParameterAsJson:@"photo/info" parameters:@{@"cmd":@"like", @"photoID":photoID} complete:^(id info){
        EZDEBUG(@"Like photo result:%@", info);
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
    }
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


//Just a trigger.
//We will return the album one at a time
//This is reverse number?
//Start mean how far away from the beginning
- (void) readAlbumInBackground:(int)start limit:(int)limit;
{
    EZDEBUG(@"Start the background thread");
    __block int count = 0;
    
    dispatch_async(_asyncQueue, ^(){
        // setup our failure view controller in case enumerateGroupsWithTypes fails
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            
            NSString *errorMessage = nil;
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"The user has declined access to it.";
                    break;
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            EZDEBUG(@"Asset access error:%@", errorMessage);
        };
        
        __block int groupCount = 1;
        __block int groupPos = 0;
        __block int photoCount = 0;
        //__block NSMutableArray* loadedPhotos = [[NSMutableArray alloc] init];
        // emumerate through our groups and only add groups that contain photos
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            //if ([group numberOfAssets] > 0)
            //{
            //[self.groups addObject:group];
            //}
            int assetCount = [group numberOfAssets];
            int begin = assetCount - start;
            EZDEBUG(@"assetCount:%i, stop:%i", assetCount, *stop);
            if(assetCount > 0){
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    EZDEBUG(@"stopped:%i, index:%i, assertCount:%i", *stop, index, assetCount);
                    ++count;
                    if(index != NSNotFound){
                        if(count >= begin){
                            
                        EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                        ed.isFront = true;
                        EZPhoto* ep = [[EZPhoto alloc] init];
                        ed.pid = ++photoCount;
                        ep.asset = result;
                        ep.assetURL = ((NSURL*)[result valueForProperty:ALAssetPropertyAssetURL]).absoluteString;
                        CLLocation* location = [result valueForProperty:ALAssetPropertyLocation];
                        if(location){
                            ep.latitude = location.coordinate.latitude;
                            ep.longitude = location.coordinate.longitude;
                        }
                        ep.createdTime = [result valueForProperty:ALAssetPropertyDate];
                        ep.isLocal = true;
                        ed.photo = ep;
                        //ed.photo.owner = [[EZPerson alloc] init];
                        ed.photo.personID = [EZDataUtil getInstance].currentPersonID;
                        
                        ep.size = [result defaultRepresentation].dimensions;
                        [_localPhotos addObject:ep];
                        EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
                        //[res insertObject:ed atIndex:0];
                        [[EZMessageCenter getInstance] postEvent:EZAlbumImageReaded attached:ed];
                        }
                        
                        //[NSThread sleepForTimeInterval:0.5];
                        if((count - begin) > limit){
                            *stop = true;
                            EZDEBUG(@"manually quit for the album reading");
                        }
                    }else{
                         //EZDEBUG(@"Will quit for the album reading");
                        [self uploadPhotoInfo:_localPhotos success:^(NSArray* arr){
                            EZDEBUG(@"Successfully uploaded photo to server");
                        } failure:^(id err){
                            EZDEBUG(@"Error to upload photo info:%@", err);
                        }];
                    }
                    
                }];
            }else{
                //++groupPos;
                EZDEBUG(@"groupPos:%i, groupCount:%i", groupPos, groupCount);
                //if(groupPos >= groupCount){
                //success(res);
                //}
            }
        };
        
        // enumerate only photos
        //ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces |
        NSUInteger groupTypes =  ALAssetsGroupSavedPhotos;
        [_assetLibaray enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}
//Now keep it simple and stupid, only change it at the second iteration
/**
- (void) loadAlbumPhoto:(int)start limit:(int)limit success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"Try to fetch %i, %i", start, limit);
    NSMutableArray* res = [[NSMutableArray alloc] init];
    //NSMutableDictionary* used = [[NSMutableDictionary alloc] init];
    
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        EZDEBUG(@"Asset access error:%@", errorMessage);
    };
    
    __block int groupCount = 1;
    __block int groupPos = 0;
    __block int photoCount = 0;
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        //if ([group numberOfAssets] > 0)
        //{
            //[self.groups addObject:group];
        //}
        int assetCount = [group numberOfAssets];
        EZDEBUG(@"assetCount:%i, stop:%i", assetCount, *stop);
        if(assetCount > 0){
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            EZDEBUG(@"stopped:%i, index:%i, assertCount:%i", *stop, index, assetCount);
            if(index != NSNotFound){
                EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                ed.isFront = true;
                EZPhoto* ep = [[EZPhoto alloc] init];
                ed.pid = ++photoCount;
                ep.asset = result;
                ep.isLocal = true;
                ed.photo = ep;
                ed.photo.owner = [[EZPerson alloc] init];
                ed.photo.owner.name = @"天哥";
                ed.photo.owner.avatar = [EZFileUtil fileToURL:@"tian_2.jpeg"].absoluteString;
                //EZDEBUG(@"Before size");
                ep.size = [result defaultRepresentation].dimensions;
                
                EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
                [res insertObject:ed atIndex:0];
            }
            
        }];
        }else{
            //++groupPos;
            EZDEBUG(@"groupPos:%i, groupCount:%i", groupPos, groupCount);
            //if(groupPos >= groupCount){
            success(res);
            //}
        }
    };
    
    // enumerate only photos
    //ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces |
    NSUInteger groupTypes =  ALAssetsGroupSavedPhotos;
    [_assetLibaray enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];}
**/

//Will upload each pending photo
//Remove the photo from the array, once it is successfuls
//Should we differentitate uploaded information and uploaded file itself?
//Let's this method call on a time out fash.
- (void) uploadPendingPhoto
{
    if(_uploadingTasks > 0){
        EZDEBUG(@"Quit for uploading, pending Task:%i", _uploadingTasks);
    }
    
    if(!self.canUpload){
        EZDEBUG(@"Quit for network not available, status:%i", _networkStatus);
    }
    NSArray* uploads = [[NSArray alloc] initWithArray:_pendingUploads];
    for(int i = 0; i < uploads.count; i++){
        
        EZPhoto* photo = [uploads objectAtIndex:i];
        if(!photo.startUpload){
            EZDEBUG(@"photo upload pending");
            continue;
        }
        if(photo.uploadPhotoSuccess){
            [_pendingUploads removeObject:photo];
        }
        if(!photo.photoID){
            EZDEBUG(@"Will start upload info for:%@", photo.photoID);
            ++_uploadingTasks;
            [[EZDataUtil getInstance] uploadPhotoInfo:@[photo] success:^(id info){
                EZDEBUG(@"Update photo info:%@", info);
                NSString* photoID = [info objectAtIndex:0];
                EZDEBUG(@"Recieved photoID:%@, currnet photoID:%@", photoID, photo.photoID);
                photo.uploadInfoSuccess = TRUE;
                photo.photoID = photoID;
                --_uploadingTasks;
            } failure:^(id err){
                EZDEBUG(@"failed to upload info for photoID:%@, :%@",photo.photoID, err);
                --_uploadingTasks;
            }];
        }
        if(!photo.uploadPhotoSuccess && photo.photoID){
            ++_uploadingTasks;
            EZDEBUG(@"Will start upload photo content for:%@", photo.photoID);
            [[EZDataUtil getInstance] uploadPhoto:photo success:^(id info){
                EZDEBUG(@"uploaded success:%@", info);
                photo.uploadPhotoSuccess = TRUE;
                photo.uploaded = TRUE;
                --_uploadingTasks;
            } failure:^(id err){
                EZDEBUG(@"failed to upload content:%@", err);
                --_uploadingTasks;
            }];
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

@end
