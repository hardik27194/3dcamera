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
    return self;
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
        NSLog(@"NAME : %@",name);
        NSLog(@"PHONE: %@",phone);
        NSLog(@"EMAIL: %@",email);
        NSLog(@"\n");
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
        person.personID = rand()/1000;
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
- (void) likedPhoto:(int)combinePhotoID success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"combinePhotoID:%i", combinePhotoID);
    dispatch_async(dispatch_get_main_queue(), ^(){
        success(nil);
    });
}

//Will get current login person id
- (int) getCurrentPersonID
{
    return 167791;
}


- (EZPerson*) getCurrentPerson
{
    EZPerson* res = [[EZPerson alloc] init];
    res.personID = [self getCurrentPersonID];
    res.name = @"天哥";
    res.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
    res.joined = true;
    return res;
}


- (EZPerson*) getPerson:(int)personID
{
    EZPerson* res = [[EZPerson alloc] init];
    res.personID = personID;
    res.name = [NSString stringWithFormat:@"天哥:%i", personID];
    if(personID % 2){
        res.avatar = [EZFileUtil fileToURL:@"img01.jpg"].absoluteString;
    }else{
        res.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
    }
    res.joined = true;
    return res;
}
//Get the person object
- (void) getPersonID:(int)personID success:(EZEventBlock)success failure:(EZEventBlock)failure;
{
    EZPerson* res = [[EZPerson alloc] init];
    res.personID = personID;
    res.name = [NSString stringWithFormat:@"天哥:%i", personID];
    if(personID % 2){
        res.avatar = [EZFileUtil fileToURL:@"img01.jpg"].absoluteString;
    }else{
        res.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
    }
    res.joined = true;
    dispatch_async(dispatch_get_main_queue(), ^(){
        success(res);
    });
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
- (void) uploadPhoto:(UIImage*)image success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    int currentUserID = [self getCurrentPersonID];
    EZPhoto* photo = [[EZPhoto alloc] init];
    photo.photoID = rand()%1000;
    //photo.ownerID = currentUserID;
    photo.owner = currentPerson;
    NSString* fullPath = [EZFileUtil saveImageToCache:image];
    photo.url = [[NSURL fileURLWithPath:fullPath] absoluteString];
    EZCombinedPhoto* cp = [[EZCombinedPhoto alloc] init];
    cp.combinedID = rand()/1000;
    cp.selfPhoto = photo;
    cp.otherPhoto = [[EZPhoto alloc] init];
    cp.otherPhoto.url = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
    //cp.otherPhoto.ownerID = rand()%1000;
    EZDisplayPhoto* dp = [[EZDisplayPhoto alloc] init];
    //dp.combinedPhotos = @[cp];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        success(dp);
    });
}

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
             NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
             [self assetURLToAsset:assetURL success:success];
         }
     }];
}

- (void) assetURLToAsset:(NSURL *)url success:(EZEventBlock)success
{
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
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

//Now keep it simple and stupid, only change it at the second iteration
- (void) loadAlbumPhoto:(int)start limit:(int)limit success:(EZEventBlock)success failure:(EZEventBlock)failure
{
    EZDEBUG(@"Try to fetch %i, %i", start, limit);
    NSMutableArray* res = [[NSMutableArray alloc] init];
    //NSMutableDictionary* used = [[NSMutableDictionary alloc] init];
    if (_assetLibaray == nil) {
        _assetLibaray = [[ALAssetsLibrary alloc] init];
    }
    
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

- (void) checkPhotoAlbum:(EZEventBlock)success failure:(EZEventBlock)failure
{
    

}

@end
