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
#define ContainerWidth 300.0

#define DefaultChatUnitHeight 95.0

#define photoPageSize 5

#define smallIconRadius 35

#define macroControlInfo(keyName) NSLocalizedStringFromTable(keyName, @"UIControlInfo", nil)

#define formatRelativeTime(time) [[EZDataUtil getInstance].timeFormatter stringFromDate:time]

#define BlurBackground RGBA(240, 240, 240, 128)

#define lightGrayBackground RGBCOLOR(217, 217, 217)
//Interesting.
#define turningMockPageTag 20070424

#define animateCoverViewTag 20000120

#define shaderSkinColor vec3(0.73,0.73,0.51)


#define longShaderSkinColor vec3(0.83,0.83, 0.61)

#define shortShaderSkinColor vec3(0.63, 0.63, 0.41)

#define shaderSkinRange 0.4

#define VinesGray RGBCOLOR(230, 231, 226);

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

//#define baseUploadURL @"http://127.0.0.1:8080/upload"
//#define baseUploadURL @"http://192.168.1.102:8080/upload"
#define baseUploadURL @"http://www.enjoyxue.com:8080/upload"

//#define baseServiceURL @"http://127.0.0.1:8080/"
//#define baseServiceURL @"http://192.168.1.102:8080/"
#define baseServiceURL @"http://www.enjoyxue.com:8080/"

#define reachableDomain @"www.enjoyzhi.com"

#define placeholdImage [UIImage imageNamed:@"user-icon-placeholder-60"] 
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

//Just put it on the end of the Array.
#define EZAlbumImageReaded @"EZAlbumImageReady"

#define EZFaceCovered @"EZFaceCovered"

#define EZTriggerCamera @"EZTriggerCamera"

#define EZZoomoutAlbum @"EZZoomoutAlbum"
#define EZZoominAlbum @"EZZoominAlbum"

#define EZCenterBigRadius 60.0

#define EZCenterSmallRadius 40.0

#define AllResizeMask UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight

#endif
