//
//  EZDataUtil.h
//  Feather
//
//  Created by xietian on 13-10-16.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EZAppConstants.h"
#import "EZPerson.h"
#import "EZPhoto.h"
#import "EZCombinedPhoto.h"
#import "EZConversation.h"
#import "LFGlassView.h"
#import "EZTrackRecord.h"
#import "UMSocial.h"

typedef enum {
    kMotherStatus,
    kChildStatus
}EZPersonSelected;
@class EZCenterButton;
@class EZPhotoChat;
@class EZProfile;
@class EZRecordTypeDesc;
@class EZStoredPhoto;
@class EZShotTask;
@class EZPhotoInfo;
@interface EZAlbumResult : NSObject

@property (nonatomic, assign) int totalPhoto;

@property (nonatomic, strong) NSArray* photos;

@end

@interface EZDataUtil : NSObject<UMSocialUIDelegate>

+ (EZDataUtil*) getInstance;

- (void) deletePhotoTask:(NSString*)taskID success:(EZEventBlock)success failed:(EZEventBlock)failed;

- (void) createPhotoInfo:(EZPhotoInfo*)photoInfo success:(EZEventBlock)success failed:(EZEventBlock)failed;

- (void) updatePhotoInfo:(EZPhotoInfo*)photoInfo success:(EZEventBlock)success failed:(EZEventBlock)failed;

- (void) createPersonID:(EZEventBlock)success failed:(EZEventBlock)failure;

- (void) queryTaskByPersonID:(NSString*)pid success:(EZEventBlock)success failed:(EZEventBlock)failure;

- (void) setSocialShareURL:(NSString*)url;

- (void) shareContent:(NSString*)text image:(UIImage*)image url:(NSString*)url controller:(UIViewController*)controller;

- (NSArray*) loadLocalTasks:(NSString*)personID;

- (void) createTaskID:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) updateTask:(EZShotTask*)task success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) deleteLocalFile:(EZStoredPhoto*)photo;

- (void) deleteStoredPhoto:(EZStoredPhoto*)photo success:(EZEventBlock)success failed:(EZEventBlock)failed;

- (void) uploadStoredPhoto:(EZStoredPhoto*)photo isOriginal:(BOOL)isOriginal success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) addUploadTask:(EZShotTask*)task success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) uploadAllTasks;

- (void) addUploadPhoto:(EZStoredPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) uploadAllPhotos;

//Normally just update the sequences
- (void) updateTaskSequence:(EZShotTask*)task success:(EZEventBlock)success failure:(EZEventBlock)failure;


- (void) queryByTaskID:(NSString*)taskID success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (NSString*) createDetailURL:(EZRecordTypeDesc*)desc date:(NSDate*)date;

- (NSString*) recordTypeToName:(EZTrackRecordType)type;

- (NSString*) recordTypeToIcon:(EZTrackRecordType)type;

- (NSString*) recordTypeToUnit:(EZTrackRecordType)type;

- (EZRecordTypeDesc*) typeToDesc:(EZTrackRecordType)type;

//The record which listed on the main page
- (NSArray*) getSelectedRecordLists:(NSString*)profileID;

- (NSArray*) getCurrentTotalRecordLists;

- (NSArray*) getTotalRecordLists:(EZProfile*)profile;

- (EZProfile*) getCurrentProfile;

- (BOOL) getTypeSelectStatus:(EZTrackRecordType)type;

- (void) saveTypeSelectedStatus:(EZTrackRecordType)type selected:(BOOL)selected;

//What's the purpose of this class
//I will recorder back. and adjust the setting accordingly
//If I keep the setting on person wise, then things could be much more simpler.
- (void) queryInitialSettings:(EZEventBlock)success failure:(EZEventBlock)failure;

//Query the current list out
- (void) queryRecordByList:(NSArray*)list success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) queryRecordByDate:(NSArray*)list date:(NSDate*)date success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) fetchCurrentRecord:(EZTrackRecordType)recordType profileID:(NSString*)profileID success:(EZEventBlock)success failure:(EZEventBlock)failure;

//Query the record type detail from server
- (void) getMostRecent:(NSString*)profileID type:(EZTrackRecordType)type success:(EZEventBlock)success failure:(EZEventBlock)block;

- (NSArray*) getPreferredRecords:(EZProfile *)profile;

@property (nonatomic, strong) NSMutableArray* uploadingTasks;

@property (nonatomic, strong) NSMutableArray* uploadingPhotos;

@property (nonatomic, strong) NSMutableDictionary* taskIDToTask;

@property (nonatomic, strong) NSDateFormatter* titleFormatter;

@property (nonatomic, strong) NSMutableDictionary* recordTypeDetails;

@property (nonatomic, strong) NSMutableDictionary* currentRecords;

//Map the id to the perferred list
@property (nonatomic, strong) NSMutableDictionary* selectedRecordLists;

@property (nonatomic, strong) NSMutableDictionary* totalRecordLists;

@property (nonatomic, strong) NSMutableArray* childRecordLists;

@property (nonatomic, strong) NSMutableArray* motherRecordLists;

//@property (nonatomic, strong) NSMutableArray* childPreferLists;

//@property (nonatomic, strong) NSMutableArray* motherPreferLists;

@property (nonatomic, strong) NSMutableArray* motherMenuItems;

@property (nonatomic, strong) NSMutableArray* childMenuItems;

@property (nonatomic, assign) EZPersonSelected currentSelected;

@property (nonatomic, strong) NSMutableArray* currentProfiles;

@property (nonatomic, assign) NSInteger currentProfilePos;

@property (nonatomic, strong) UIImage* placeHolder;

//Which will include both mother and the child list
- (void) createAllRecordType;

- (void) fetchProfilesForID:(NSString*)personID success:(EZEventBlock)success failure:(EZEventBlock)failure;


- (NSArray*) getMenuItemByType:(EZProfile*)profile;

- (NSArray*) getCurrentMenuItems;

//The id which will be used to query it's status.
@property (nonatomic, strong) NSString* queryPersonID;

@property (nonatomic, strong) EZEventBlock avatarSuccess;

@property (nonatomic, strong) EZEventBlock avatarFailed;

@property (nonatomic, strong) NSMutableDictionary* personPhotoCount;

@property (nonatomic, assign) int queryingCount;

@property (nonatomic, assign) BOOL isQueryingNotes;

@property (nonatomic, strong) EZCenterButton* centerButton;

@property (nonatomic, strong) UIView* barBackground;

@property (nonatomic, strong) ALAssetsLibrary* assetLibaray;

@property (nonatomic, strong) NSMutableArray* mainPhotos;

@property (nonatomic, strong) NSMutableArray* mobileNumbers;

//@property (nonatomic, strong) NSMutableArray* mainNonSplits;

//This queue are used to execute the task without blocking the front end
@property (nonatomic, strong) dispatch_queue_t asyncQueue;

//For test purpose only
@property (nonatomic, assign) NSInteger photoCount;

@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;

@property (nonatomic, assign) BOOL isWifiAvailable;

@property (nonatomic, assign) BOOL networkAvailable;

@property (nonatomic, assign) BOOL wifiOnly;

@property (nonatomic, strong) NSString* version;

//All the friend
@property (nonatomic, strong) NSMutableArray* contacts;

//The person are login to the server.
@property (nonatomic, strong) NSString* currentPersonID;

@property (nonatomic, strong) NSDateFormatter* inputDateFormatter;

@property (nonatomic, strong) NSDateFormatter* generalDateTimeFormatter;

@property (nonatomic, strong) NSDateFormatter* birthDateFormatter;

@property (nonatomic, strong) NSDateFormatter* isoFormatter;

@property (nonatomic, strong) NSDateFormatter* isoFormatter2;

@property (nonatomic, strong) NSMutableArray* localPhotos;

@property (nonatomic, strong) EZPerson* currentLoginPerson;

//Photos that are waiting to be uploaded
@property (nonatomic, strong) NSMutableArray* pendingUploads;

//Shot photo waiting to get the matched photo.
//A good change to use the KV listener.
@property (nonatomic, strong) NSMutableArray* pendingPhotos;
//Act as a hashed Link list
@property (nonatomic, strong) NSMutableArray* sortedUsers;

@property (nonatomic, strong) NSMutableSet* sortedUserSets;

@property (nonatomic, strong) NSMutableSet* pendingUserQuery;

@property (nonatomic, strong) NSMutableDictionary* pendingPersonCall;

@property (nonatomic, strong) NSMutableDictionary* currentQueryUsers;

//Used to check if the notes was triggered by user, if it is we would like to
//switch user to that person and scroll to the photo then waiting for the photo to show off
//This is just great. I love this game.
@property (nonatomic, strong) NSMutableDictionary* pushNotes;

@property (nonatomic, strong) NSMutableSet* joinedUsers;

@property (nonatomic, strong) NSMutableSet* notJoinedUsers;

@property (nonatomic, strong) UIImageView* prefetchImage;

@property (nonatomic, strong) NSMutableDictionary* downloadedImages;

@property (nonatomic, strong) NSMutableArray* currentPhotos;

@property (nonatomic, strong) NSDateFormatter* timeFormatter;

@property (nonatomic, strong) LFGlassView* naviBarBlur;

@property (nonatomic, strong) AFHTTPResponseSerializer* imageSerializer;

@property (nonatomic, strong) EZClickView* contactButton;

//People can use this cover whenever he want.
@property (nonatomic, strong) EZClickView* totalCover;

@property (nonatomic, strong) EZEventBlock timerBlock;

@property (nonatomic, strong) NSMutableDictionary* recievedNotify;

//@property (nonatomic, assign) int uploadingTasks;

@property (nonatomic, strong) NSMutableDictionary* cachedPointer;

@property (nonatomic, assign) BOOL pauseUpload;

@property (nonatomic, strong) AFNetworkReachabilityManager* manager;

@property (nonatomic, strong) NSArray* updatedPersons;

//Once the avatar is uploaded successfully, I will set it to nil
@property (nonatomic, strong) NSString* avatarFile;

@property (nonatomic, assign) BOOL uploadingAvatar;

@property (nonatomic, strong) NSString* avatarURL;

@property (nonatomic, strong) NSString* prevFaceID;

//Check the current status
- (BOOL) canUpload;

- (void) uploadPendingPhoto;

- (void) queryPendingPerson;

- (void) queryNotify;

- (NSDate*) formatISOString:(NSString*)string;

- (NSString*) getCurrentPersonID;

- (void) setupNetworkMonitor;

- (void) jumpCycleAnimation:(EZEventBlock)callBack;
//@property (nonatomic, strong) NSMutable
//Phone number will be the unique id?
//Mean only one id for each phone right?
//@property (nonatomic, strong) NSString* phoneNumber;
//Will load data for user
- (void) loadFriends:(EZEventBlock)success failure:(EZEventBlock)failure;

- (NSMutableDictionary*) calculatePersonPhotoCount;

//The purpose is to remove all the photos after login.
//Leave person when user login.
- (void) cleanDBPhotos;

//If all the photo book uploaded, then I could get from the map immediately.
//Else i will call the old method.
- (NSArray*) getSortedPersons:(EZEventBlock)successBlck;
//called at logout, so that no user trace will left.
- (void) cleanLogin;
//Should I give the person id or what?
//Let's give it. Expose the parameter make the function status free. More easier to debug
- (void) likedPhoto:(NSString*)photoID ownPhotoID:(NSString*)ownPhotoID like:(BOOL)like success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) uploadMobile:(NSArray*)arr success:(EZEventBlock)success;

- (void) prefetchImage:(NSString*) url success:(EZEventBlock)success failure:(EZEventBlock)failure;

//- (void) exchangePhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) exchangeWithPerson:(NSString*)matchPersonID photoID:(NSString*)photoID success:(EZEventBlock)success failure:(EZEventBlock)failure;
//Why this method?
//Normally, the person is already in the cache by check the photos.
- (EZPerson*) getPerson:(NSString*)personID;

//I will have the related user query out.
//I will get the face to the respective id.it will be the attached information.
//it will be incapsulated in this API.
- (void) detectFace:(UIImage*)image success:(EZEventBlock)success failure:(EZEventBlock)failure;
- (void) trainFace:(UIImage*)image success:(EZEventBlock)success failure:(EZEventBlock)failure;

//I will create a group which will based on my current group.
- (void) createFaceGroup:(NSString*)groupName;

- (void) registerUser:(NSDictionary*)person success:(EZEventBlock)success error:(EZEventBlock)error;

- (void) registerMockUser:(EZEventBlock)success error:(EZEventBlock)error;

- (void) loginUser:(NSDictionary*)loginInfo success:(EZEventBlock)success error:(EZEventBlock)error;

//What's the purpose of this
//Whether we allow the login page to show off or not.
- (void) triggerLogin:(EZEventBlock)success failure:(EZEventBlock)failure reason:(NSString*)reason isLogin:(BOOL)isLogin;


- (void) deletePhoto:(EZPhoto *)photoInfo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) disbandPhoto:(EZPhoto *)photoInfo destPhoto:(EZPhoto*)destPhoto success:(EZEventBlock)success failure:(EZEventBlock)failure;
//This method will enable the user to upload all it's contacts information to the server.
//The server will get the uploaded information and return a list which update the current user information.
//What, I should do?
//I will have a method to allow the person to check if it need any update or not.
//Following is the psudo code: if person.changed(), [EZMessageCenter postMessage(updatedPerson, person);
//The this one could be a periodic update.
- (void) uploadContacts:(NSArray*)contacts success:(EZEventBlock)succss failure:(EZEventBlock)failure;

//Internal invokation only.
- (void) queryPersonIDs:(NSArray*)personIDs success:(EZEventBlock)success failure:(EZEventBlock)failure;
//Get the person object
//- (EZPerson*) getPerson:(int)personID;
//Check cache first, if not then will query the person
- (EZPerson*) getPersonByID:(NSString*)personID success:(EZEventBlock)success;


//When recieve the person from the server side, what do we need to do?
- (EZPerson*) updatePerson:(EZPerson*)person;

//Get converstaion regarding this photo
- (void) getConversation:(int)combineID success:(EZEventBlock)success failure:(EZEventBlock)failure;

//Adjust the sequence for the users
- (void) adjustActivity:(NSString*)personID;

- (NSString*) normalizeMobile:(NSString*)mobile;
//The Photo object will returned.
//How about thumbnail.
//Should we generate it dynamically.
//Maybe we should.
- (NSString*) urlToThumbURL:(NSString*)normalURL;

- (void) uploadPhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) uploadAvatar:(UIImage*)img success:(EZEventBlock)success failure:(EZEventBlock)failure;


- (void) addPhotoChat:(EZPhoto*)ownPhoto otherPhoto:(EZPhoto*)otherPhoto chat:(EZPhotoChat*)chat success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) addPhotoChat:(EZPhotoChat*)chat success:(EZEventBlock)success failure:(EZEventBlock)failure;


- (void) queryPhotoChat:(EZPhoto*)ownPhoto otherPhoto:(EZPhoto*)otherPhoto success:(EZEventBlock)success failure:(EZEventBlock)failure;


- (void) queryByChatID:(NSString*)chatID success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) addConverstaion:(int)combinedID text:(NSString*)text success:(EZEventBlock)success failure:(EZEventBlock)failure;

//Send invite request
- (void) inviteFriend:(EZPerson*)person success:(EZEventBlock)success failure:(EZEventBlock)failure;

//Will check the combined photo from a particular person
//- (void) getCombinedPhoto:(int)personID start:(int)start limit:(int)limit success:(EZEventBlock)success failure:(EZEventBlock)failure;

//I will try to get the all the user from the address book.
//Every time user get to the contact page will call it?
//This is small detail, which is poilicy. Let's define this later.
- (void) getAllContacts:(EZEventBlock)blk;

- (void) getMatchUsers:(EZEventBlock)block failure:(EZEventBlock)failure;
//- (void) uploadAvatar:()
//When need to call this?
//When I get the photo album access, I will upload all the extracted photo information
//Then I will update the photo information to the server side.
//Need to take wifi into consideration.
//But this can be done transparently, right?
//YES.
//For the success, I will update the database.
//Next time I will use file name hash to check if any new photo insert into the album.
- (void) uploadPhotoInfo:(NSArray*)photoInfo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) cancelPrematchPhoto:(EZPhoto*)photo success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) queryPhotos:(int)page pageSize:(int)pageSize otherID:(NSString*)otherID success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) removeLocalPhoto:(NSString*)photoID;

- (void) removeLocalPhotoByPos:(NSInteger)pos;

- (int) removeOtherPhoto:(NSString*)photoID array:(NSMutableArray*)arr store:(BOOL)store;

- (void) cleanAllLoginInfo;

- (void) deleteImageFiles:(NSArray *)photos;

- (void) deleteImageFile:(EZPhoto*)photo;

//Will check if any new photo in the album.
//I will use the filename as hash?
//Could I get any of that?
- (void) checkPhotoAlbum:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) fetchImageFromAssetURL:(NSString*)url  success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) getPhotoBooks:(EZEventBlock)blk;
//Have thumbnail eat up all memory was not a good thing to do.
//So I will use this method to pervent this from happening
- (void) loadAlbumPhoto:(int)start limit:(int)limit success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (NSString*) getTimeString:(NSDate*) date;


//All the album photo will get loaded as EZDisplayPhoto,
//Then I will try to load the photo from server side see what's the current status of the photo.
//cool, let's do it.
- (void) loadAlbumAsDisplayPhoto:(int)start limit:(int)limit success:(EZEventBlock)success failure:(EZEventBlock)failure;
//How many photos in the album.
//Which is unful when I try to browse through the whole album.
- (void) getAlbumPhotoCount:(EZEventBlock)success;

- (void) saveImage:(UIImage*)shotImage success:(EZEventBlock)success failure:(EZEventBlock)failure;

//- (void) raiseRegisterProcess:

- (void) assetURLToAsset:(NSURL*)url success:(EZEventBlock)success;


- (void) setAssetUsed:(NSString*) asset;
//Get last unused image
- (void) fetchLastImage:(EZEventBlock)success failure:(EZEventBlock)failure;
//Just a trigger.
//We will return the album one at a time
- (void) readAlbumInBackground:(int)start limit:(int)limit;

- (void) loadPhotoBooks;
//For the preload image, if I have local url in the cache, I will return it immediately.
//Otherwise, I will dump use the thumbnail.
- (NSString*) preloadImage:(NSString*)fullURL success:(EZEventBlock)success failed:(EZEventBlock)failed;

//I will load the small image first, then the large image
- (void) serialPreload:(NSString*)fullURL;

- (void) serialLoad:(NSString*)fullURL fullOk:(EZEventBlock)fullBlock thumbOk:(EZEventBlock)thumbOk pending:(EZEventBlock)pending failure:(EZEventBlock)failure;
//Will upload each pending photo
//Remove the photo from the array, once it is successfuls

- (void) checkAndUpload:(NSArray*)persons;

//Read all the photos stored in the local database
- (NSArray*) getStoredPhotos;

- (void) storeAll;

- (void) storeAllPhotos:(NSArray*)photo;

- (void) addDeleteTask:(EZPhoto*)photo;

- (void) storeAllPersons:(NSArray*)persons;

- (EZPhoto*) getStoredPhotoByID:(NSString*)photoID;

- (NSArray*) getStoredPersonLists;

- (NSMutableDictionary*) getStoredPersons;

- (void) updatePerson:(NSDictionary*)dict success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) loadAllPersons;

- (void) remoteDebug:(NSString*)info isSync:(BOOL)isSync;

- (void) requestSmsCode:(NSString*)number success:(EZEventBlock)success failure:(EZEventBlock)failure;

- (void) addPendingUpload:(EZPhoto*)photo;

- (void) storePendingPhoto;

- (void) uploadAvatarImage:(UIImage*)image success:(EZEventBlock)success failed:(EZEventBlock)failed;

- (void) uploadAvatar;

//Will return the array which will have the photo displayed for the firstTime
- (NSArray*) getFirstTimeArray;


- (void) fillPhotoCount:(NSArray*)persons;

- (int) getPendingForPerson:(NSString*)personID filterType:(int)filterType;

- (void) removeExpiredPhotos;

- (void) sendTouches:(EZPerson*)ps touches:(NSArray*)touches  success:(EZEventBlock)success failed:(EZEventBlock)failed;

@end
