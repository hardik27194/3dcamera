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
#define EZStatusBarBackgroundColor [UIColor blackColor]

#define CenterUpShift 20

#define EZRotateAnimDuration 0.5
//RGBCOLOR(0, 197, 213);

#define macroHideStatusBar(flag) [[UIApplication sharedApplication] setStatusBarHidden:flag withAnimation:UIStatusBarAnimationFade]

#define CurrentScreenWidth [UIScreen mainScreen].bounds.size.width 

#define CurrentScreenHeight [UIScreen mainScreen].bounds.size.height

#define ContainerWidth 300.0

#define DefaultChatUnitHeight 95.0

#define photoPageSize 5

#define smallIconRadius 35

#define url2thumb(url) [[EZDataUtil getInstance] urlToThumbURL:url]

#define pid2person(pid) [[EZDataUtil getInstance] getPersonByID:pid success:nil]

#define pid2personCall(pid, call) [[EZDataUtil getInstance] getPersonByID:pid success:call]


#define preloadimage(url) [[EZDataUtil getInstance] serialPreload:url]

//#define preloadcallback(url, success, failure) [[EZDataUtil getInstance] preloadImage

#define macroControlInfo(keyName) NSLocalizedStringFromTable(keyName, @"UIControlInfo", nil)

#define formatRelativeTime(time) [[EZDataUtil getInstance].timeFormatter stringFromDate:time]

#define BlurBackground RGBA(240, 240, 240, 128)

#define lightGrayBackground RGBCOLOR(217, 217, 217)
//Interesting.
#define turningMockPageTag 20070424

#define animateCoverViewTag 20000120

#define shaderSkinColor vec3(0.73,0.73,0.51)

//The purpose of this even is to setup the Current Album user, so that user could load
//The photo shared with this user
#define EZSetAlbumUser @"EZSetAlbumUser"

#define BlackBarImage [UIImage imageWithColor:RGBA(0, 0, 0, 50)]

#define ClearBarImage [UIImage imageWithColor:RGBA(0, 0, 0, 0)]

#define longShaderSkinColor vec3(0.85,0.85, 0.0)

#define blueShaderColor vec3(0.0, 0.0, 1.0)

#define shortShaderSkinColor vec3(0.63, 0.63, 0.41)

#define shaderSkinRange 0.4

#define VinesGray RGBCOLOR(190, 180, 180)

#define CellBackground [UIColor blueColor]

#define normalBarTitleColor RGBCOLOR(144,126,117)

#define functionalBarTitleColor RGBCOLOR(79,79,79)

#define defaultDarkColor RGBCOLOR(40, 40, 40)

#define darkTextColor RGBCOLOR(80, 80, 80)

#define lightTextColor  RGBCOLOR(140, 140, 140)

#define pointValue(x,y) [NSValue valueWithCGPoint:CGPointMake(x, y)]


#define currentPerson [[EZDataUtil getInstance] getCurrentPerson] 

#define randBack(color)  [[EZUIUtility sharedEZUIUtility] getBackgroundColor:color]

#define null2Empty(str) str?str:@""

#define isoDateFormat(curDate) [[EZDataUtil getInstance].isoFormatter stringFromDate:curDate]

#define isoStr2Date(curStr) [[EZDataUtil getInstance].isoFormatter dateFromString:curStr]


#define inviteMessageURL @"http://www.enjoyxue.com:8080/"

#define baseUploadURL @"http://10.0.1.6:8080/upload"
//#define baseUploadURL @"http://192.168.1.102:8080/upload"
//#define baseUploadURL @"http://www.enjoyxue.com:8080/upload"
//#define baseUploadURL @"http://172.13.0.49:8080/upload"

#define baseServiceURL @"http://10.0.1.6:8080/"
//#define baseServiceURL @"http://192.168.1.102:8080/"
//#define baseServiceURL @"http://www.enjoyxue.com:8080/"
//#define baseServiceURL @"http://172.13.0.49:8080/"

#define EZButtonGreen RGBCOLOR(56, 216, 116)

#define reachableDomain @"www.enjoyzhi.com"

#define placeholdImage [UIImage imageNamed:@"head_icon"] 
//This is from show hair.
//Who will manage the session.
//From Mobile's perspective, I should handle the session.
#define EZCurrentSessionID @"EZCurrentSessionID"

#define EZPhotoUploadSuccess @"EZPhotoUploadSuccess"

#define EZSessionHeader @"x-current-personid"
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

#define EZTakePicture @"EZTakePicture"

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


#define EZCenterBigRadius 60.0

#define EZCenterSmallRadius 70.0

#define EZOuterCycleRadius  15.0

#define EZInnerCycleRadius 22.0


#define AllResizeMask UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight

#endif
