//
//  EZAppConstants.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#ifndef Feather_EZAppConstants_h
#define Feather_EZAppConstants_h
#include "EZConstants.h"
//#include <opencv2/opencv.hpp>
//Will hold the Application related constants.

typedef enum {
    kUploadInit,
    kUploadStart,
    kUploadFailure,
    kUploadDone
} EZUploadStatus;

typedef enum {
    kOwnPageType,
    kOtherPageType
} EZContactDisplayType;

typedef enum {
    kMessageTab,
    kPartyTab,
    kFriendTab,
    kMyselfTab
} EZTabType;


typedef enum {
    kPooh,
    kUrine,
    kSleep,
    kFeeds,
    kMilk,
    kAuxFood,
    kHeight,
    kWeight,
    kHeadCycle,
    kChestCycle,
    kBloodExam,
    kBellyCycle,
    kWalkCount,
    kBloodPressure,
    kBloodSugar,
    kRecipes,
    kInfantTeach,
    kExamRecord,
    kMotherWeight
} EZTrackRecordType;

typedef enum {
    kDateValue,
    kFloatValue,
    kStringValue
} EZinputValueType;

#define EZShotPhotos @"EZShottedPhotos"

#define EZPasswordInputHeight 45.0

#define EZLoginInputTextColor RGBCOLOR(107, 107, 107)

#define EZListChangedEvent @"EZListChangedEvent"

#define EZUpdateSelection @"EZUpdateSelection"

#define EZEverSaved @"EZEverSaved"

#define EZRecordDetailHeight 89

#define EZProfileCellHeight 164

#define EZMainCellHeight 84

#define ToolBarTextColor RGBCOLOR(62, 58, 57)

//turn the track record type to icons
#define type2icon(typeID)  

#define type2unit(typeID)

#define type2name(typeID)

#define type2desc(typeID) [[EZDataUtil getInstance] typeToDesc:typeID]

#define ToolBarBackground RGBCOLOR(237, 240, 245)

#define GrayTextColor RGBCOLOR(70, 70, 70)

#define  EZLargeFont [UIFont fontWithName:@"HelveticaNeue-Light" size:25]
#define  EZSmallFont [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30]

#define  EZTitleSlimFont [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40]
#define  EZTitleFontCN [UIFont fontWithName:@"STHeitiSC-Light" size:20]

#define  EZRemindFontCN [UIFont fontWithName:@"STHeitiSC-Light" size:18]


#define  EZOriginalTitle  @"feather"

#define EZStatusBarBackgroundColor [UIColor blackColor]

#define CenterUpShift 20

#define EZPersonCellHeight 84

#define EZToolStripeHeight 74

#define EZProfileImageHeight 360

#define EZRotateAnimDuration 0.5

#define EZRaiseAnimationDuration 0.3
//RGBCOLOR(0, 197, 213);

#define macroHideStatusBar(flag) [[UIApplication sharedApplication] setStatusBarHidden:flag withAnimation:UIStatusBarAnimationFade]

#define CurrentScreenWidth [UIScreen mainScreen].bounds.size.width 

#define CurrentScreenHeight [UIScreen mainScreen].bounds.size.height

#define ContainerWidth 300.0

#define EZMaxAdaptiveFont 40

#define EZMinAdaptiveFont 15

#define DefaultChatUnitHeight 95.0

#define photoPageSize 1500

#define smallIconRadius 35

#define url2thumb(url) [[EZDataUtil getInstance] urlToThumbURL:url]

#define pid2person(pid) [[EZDataUtil getInstance] getPersonByID:pid success:nil]

#define pid2personCall(pid, call) [[EZDataUtil getInstance] getPersonByID:pid success:call]

#define normalizeMb(mobile) [[EZDataUtil getInstance]normalizeMobile:mobile]

#define checkimageload(url) [[EZDataUtil getInstance] preloadImage:url success:nil failed:nil]

#define preloadimage(url) [[EZDataUtil getInstance] serialPreload:url]

//#define preloadcallback(url, success, failure) [[EZDataUtil getInstance] preloadImage

#define macroControlInfo(keyName) NSLocalizedStringFromTable(keyName, @"UIControlInfo", nil)

//#define formatRelativeTime(time) [[EZDataUtil getInstance].timeFormatter stringFromDate:time]
#define formatRelativeTime(time) [[EZDataUtil getInstance] getTimeString:time]

#define BlurBackground RGBA(240, 240, 240, 128)

#define ButtonWhiteColor RGBA(230, 230, 230, 225)

#define NaviBarBlack RGBACOLOR(0, 0, 0, 60)

#define lightGrayBackground RGBCOLOR(217, 217, 217)
//Interesting.
#define turningMockPageTag 20070424

#define animateCoverViewTag 20000120

#define shaderSkinColor vec3(0.73,0.73,0.51)

#define EZHeartSymbol @"♡"

//The purpose of this even is to setup the Current Album user, so that user could load
//The photo shared with this user
#define EZSetAlbumUser @"EZSetAlbumUser"

#define BlackBarImage [UIImage imageWithColor:RGBA(0, 0, 0, 50)]

#define ClearBarImage [UIImage imageWithColor:RGBA(0, 0, 0, 0)]

#define longShaderSkinColor vec3(0.85,0.85, 0.0)

#define blueShaderColor vec3(0.0, 0.0, 1.0)

#define shortShaderSkinColor vec3(0.63, 0.63, 0.41)

#define shaderSkinRange 0.4

#define EZEnlargeIconRatio 1.5

#define EZOrangeColor RGBCOLOR(255, 81, 57)

#define VinesGray RGBCOLOR(180, 190, 190)

#define CellBackground [UIColor blueColor]

#define normalBarTitleColor RGBCOLOR(144,126,117)

#define functionalBarTitleColor RGBCOLOR(79,79,79)

#define defaultDarkColor RGBCOLOR(40, 40, 40)

#define EZAppleBlue RGBCOLOR(14, 143, 247)

#define darkTextColor RGBCOLOR(80, 80, 80)

#define lightTextColor  RGBCOLOR(140, 140, 140)

#define pointValue(x,y) [NSValue valueWithCGPoint:CGPointMake(x, y)]

#define currentLocalLang [[NSLocale preferredLanguages] objectAtIndex:0]

#define currentPerson [[EZDataUtil getInstance] getCurrentPerson] 

#define randBack(color)  [[EZUIUtility sharedEZUIUtility] getBackgroundColor:color]

#define null2Empty(str) str?str:@""

#define isoDateFormat(curDate) [[EZDataUtil getInstance].isoFormatter stringFromDate:curDate]

#define isoStr2Date(curStr) [[EZDataUtil getInstance] formatISOString:curStr]

#define EZNoteCountChange @"EZNoteCountChange"

#define EZNoteCountSet @"EZNoteCountSet"

#define EZUploadedMobile @"EZUploadedMobile"

#define EZPositionHold @"EZPositionHold"

#define EZDeleteOtherPhoto @"EZDeleteOtherPhoto"

#define EZRecievedChat @"EZRecievedChat"

#define EZPurposeInfo macroControlInfo(@"按下快门\n捕获他(她)的照片。")

#define EZSetPasswordInfo macroControlInfo(@"重设密码")

#define FullHeartImage [EZUIUtility sharedEZUIUtility].fullHeart

#define EmptyHeartImage [EZUIUtility sharedEZUIUtility].emptyHeart

#define PressedHeartImage [EZUIUtility sharedEZUIUtility].pressedHeart

#define LeftHeartImage [EZUIUtility sharedEZUIUtility].leftHeart

#define RightHeartImage [EZUIUtility sharedEZUIUtility].rightHeart


#define miniDiskSpace  500000

#define expiredTime 86400

#define personTimeout 900

#define err2StatusCode(error) [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode]


#define path2image(path) [UIImage imageWithContentsOfFile:url2fullpath(path)]

//If there are production user,
//Then will send to production push server.
//If not we will send to sandbox server
#define EZProductFlag @"1"

#define inviteMessageURL @"http://www.enjoyxue.com:8080/"

//#define baseUploadURL @"http://172.13.0.127:8080/upload"
//#define baseUploadURL @"http://10.0.1.6:8080/upload"
#define relativeUploadURL @"p3d/upload"
//#define baseUploadURL @"http://192.168.0.150:8080/upload"
//#define baseUploadURL @"http://192.168.1.101:8080/upload"
//#define baseUploadURL @"http://192.168.1.101:8080/upload"

//#define baseServiceURL @"http://172.13.0.127:8080/"
//#define baseServiceURL @"http://10.0.1.6:8080/"
//every request need to have session with it.
//#define baseServiceURL @"http://www.enjoyxue.com:8080/%@;jsessionid=%@?"
#define baseServiceURL @"http://192.168.1.105:8080/"
//#define baseServiceURL @"http://192.168.1.101:8080/"
//#define baseServiceURL @"http://192.168.1.101:8080/"

#define EZButtonGreen RGBCOLOR(56, 216, 116)

#define EZButtonRed RGBCOLOR(216, 116, 56)

#define ClickedColor RGBCOLOR(62, 192, 216)

#define EZBarButtonColor RGBCOLOR(62, 192, 216)

#define EZEmptyColor RGBA(255,255,255,120)//[UIColor whiteColor]
#define EZOwnColor RGBCOLOR(101, 247, 231)
#define EZOtherColor RGBCOLOR(247, 231, 101)
#define EZAllLikeColor RGBCOLOR(61, 191, 216)



#define reachableDomain @"www.google.com"

#define placeholdImage [UIImage imageNamed:@"head_icon"] 
//This is from show hair.
//Who will manage the session.
//From Mobile's perspective, I should handle the session.
#define EZCurrentSessionID @"EZCurrentSessionID"

#define EZContactsReaded @"EZContactsReaded"

#define EZRaisePersonDetail @"EZRaisePersonDetail"

#define EZPhotoUploadSuccess @"EZPhotoUploadSuccess"

#define EZNetworkStatus @"EZNetworkStatus"

#define EZTokenUploaded @"EZTokenUploaded"

#define EZUserEditted @"EZUserEditted"

#define EZSessionHeader @"x-current-personid"

#define EZProductionHeader @"x-prod"
//Will move screen from one to another.
#define EZScreenSlide @"EZScreenSlide"

//Once shot a photo will boardcast a message to change the cover
#define EZCoverImageChange @"EZCoverImageChange"

#define EZGetContacts @"EZGetContacts"

//The contacts page will get update by the new message
#define EZUpdateContacts @"EZUpdateContacts"
//Will get called when the camera used and the image get selected.
#define EZCameraCompleted @"EZCameraCompleted"

#define EZCameraIsReady @"EZCameraIsReady"

#define EZResumeNetwork @"EZResumeNetwork"

#define EZTakePicture @"EZTakePicture"

#define EZShowShotButton @"EZShowShotButton"

#define EZRecoverShotButton @"EZRecoverShotButton"

#define EZStatusBarChange @"EZStatusBarChange"

//Just put it on the end of the Array.
#define EZAlbumImageReaded @"EZAlbumImageReady"

#define EZFaceCovered @"EZFaceCovered"

#define EZTriggerCamera @"EZTriggerCamera"

#define EZZoomoutAlbum @"EZZoomoutAlbum"
#define EZZoominAlbum @"EZZoominAlbum"

#define EZRecievedNotes @"EZRecievedNotes"

//Doesn't gurantee that the user is a mock or official user
#define EZUserAuthenticated @"EZUserAuthenticated"

#define EZALRecievedNotes @"EZALRecievedNotes"

#define EZALContactPage @"EZALContactPage"

#define EZALCameraShot @"EZALCameraShot"

#define EZInviteFriend @"EZInviteFriend"

#define EZInviteFriendResult @"EZInviteFriendResult"

#define EZExceptionQuit @"EZExceptionQuit"

#define EZAlbumImageUpdate @"EZAlbumImageUpdate"

#define EZAlbumNewImage @"EZAlbumNewImage"

#define EZALCameraAlbum @"EZALCameraAlbum"

#define EZALCameraConfirm @"EZALCameraConfirm"

#define EZALInputComment @"EZALInputComment"

#define EZALCameraCancel @"EZALCameraCancel"

#define EZALLogout @"EZALLogout"

#define EZALLogin @"EZALLogin"

#define EZAlbumImageClean @"EZAlbumImageClean"

#define EZALStartPeriod @"EZALStartPeriod"

#define EZUsedAlbumPhotos @"EZUsedAlbumPhotos"

#define EZOldPhotoAssetURL @"EZOldPhotoAssetURL"

#define EZExpiredPhotos @"EZExpiredPhotos"

#define EZNotFirstTime @"EZNotFirstTime"

#define EZAvatarURL @"EZAvatarURL"

#define EZAvatarFileName @"EZAvatarFileName"

#define featherIconImage [UIImage imageNamed:@"feather_icon"]

#define DefaultEmptyString  macroControlInfo(@"同时拍摄的人")

#define EZCenterBigRadius 60.0

#define EZCenterSmallRadius 70.0

#define EZShotButtonDiameter 46

#define EZOuterCycleRadius  15.0

#define EZInnerCycleRadius 22.0

#define EZCharLimit 25

typedef enum {
    kPersonFilter,
    kPhotoWaitFilter,
    kPhotoNewFilter,
    kPhotoAllLike,
    kPhotoOtherLike,
    kPhotoOwnLike
}EZFilterType;



#define AllResizeMask UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight

#endif
