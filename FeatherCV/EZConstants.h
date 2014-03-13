//
//  EZConstants.h
//  SchoolCommunity
//
//  Created by xietian on 13-1-11.
//  Copyright (c) 2013年 xietian. All rights reserved.
// Comments again

#ifndef SchoolCommunity_EZConstants_h
#define SchoolCommunity_EZConstants_h


typedef void (^EZOperationBlock)();

//I just keep making the same mistake. which is ok.
//Make all the mistake you could and enjoy doing it.
//Used to handle the events, passing the sender to aviod cyclic reference holder.
typedef void (^ EZEventBlock)(id sender);

typedef void (^ EZConverterBlock) (id sender, id target);

typedef int (^ EZConditionBlock) (id src, id dest);

typedef int (^ EZTabSelectCheck) (NSInteger tabIndex);

typedef int (^ EZAnimateBlock) ();

typedef void (^ EZProgressCheck) (CGFloat percent);

//The callback for the picker we used.
typedef void (^ EZPickerSelected) (int component, id value);


//Cool, decouple the timeline with the context
typedef void (^ EZQueryBlock) (NSInteger start, NSInteger limit, EZEventBlock success, EZEventBlock error);

typedef void (^ EZSearchBlock)(NSString* keyword, NSInteger start, NSInteger limit, EZEventBlock success, EZEventBlock error);

//What's the purpose of this method?
//It will be used to trigger the retry.
//For example, If the upload task is a retry action,when it failed, it could insert it's self again.
//So it is natural borned once.
typedef void (^ EZRetryBlock) (id sender, EZOperationBlock retry);

//As an old dog, I learnt some new tricks.
#define SINGLETON_FOR_HEADER(classname) + (classname *)shared##classname;

#define SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
shared##classname = [[classname alloc] init];\
});\
\
return shared##classname; \
}


#define dispatch_later(timeval, body)  double delayInSeconds = timeval; \
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)); \
dispatch_after(popTime, dispatch_get_main_queue(), body)

#define dispatch_main(body) dispatch_async(dispatch_get_main_queue(), body)

//Weixin related constants
#define EZAppID @"a95992fc1a43415593de3643ecfa9a60"
#define EZWeixinAppID @"wxc6b37b77dff0ad2d" 


//Weibo related constants
#define kAppKey             @"2523578306"
#define kAppSecret          @"1732af7483a2f9aa804714f442790776"
#define kAppRedirectURI     @"http://liangne.com/oauth/weibo/redirect"

//Why do I need this?
//So that I could format the date to correct format
#define EZJsonDateFormatter @"yyyy-MM-dd'T'HH:mm:ss"

#define nonull(str) str?str:@""

#define isRetina4 ([[UIScreen mainScreen] bounds].size.height == 568)

#define isRectEqual(rect1, rect2) (rect1.origin.x == rect2.origin.x && rect1.origin.y == rect2.origin.y && rect1.size.width == rect2.size.width && rect1.size.height == rect2.size.height)

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)/255.0f]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:(a)]

#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)/255.0f]


#define FeedTextGrayColor RGBCOLOR(195,195,195)

#define FeedNormalText RGBCOLOR(79,79,79)

#define EditorCellText RGBCOLOR(79,79,79)

#define EditorCellEditableText RGBCOLOR(79,79,79)

#define FeedNameText RGBCOLOR(62,142, 168)

#define FeedButtonText RGBCOLOR(144, 126, 117)

#define FeedImageBorder RGBCOLOR(199, 199, 199)

#define FeedBarBorder RGBCOLOR(226, 226, 226)

#define FeedStylistPosition RGBCOLOR(93, 93, 93)

#define FeedStylistSkillSet RGBCOLOR(189, 189, 189)

#define FeedMagazineTitle RGBCOLOR(214, 193, 170)

#define TextPlaceHolder RGBCOLOR(204, 204, 204)

#define FeedAddTagText RGBCOLOR(148, 138, 138)

#define TagAddTitle  RGBCOLOR(67, 67, 67)

#define TagSelectedBorder RGBCOLOR(218, 84, 25)

#define TagNormalBorder RGBCOLOR(228, 227, 226)

#define TagPageControl RGBCOLOR(220, 81, 21)

#define TagSelectionSeperator RGBCOLOR(226, 225, 223)

#define AlbumSeperatorColor RGBCOLOR(176, 163, 148)

#define insertObject(arr, obj) arr?[arr insertObject:obj]:@[obj]

#define removeObject(arr, obj) [arr removeObject:obj]

#define rectWrap(rect) [NSValue valueWithCGRect:rect]

#define insertArray(arr, objs) arr?[arr insertObjects:objs]:objs

#define TopView [[UIApplication sharedApplication] keyWindow]
#define AddTopView(view) [UIApplication addTopView:view]


#define PlaceHolderSmall [UIImage imageNamed:@"head_icon"]
#define PlaceHolderMiddle [UIImage imageNamed:@"user-icon-placeholder-100"]
#define PlaceHolderLarge [UIImage imageNamed:@"user-icon-placeholder-120"]
#define PlaceHolderLargest [UIImage imageNamed:@"user-icon-placeholder-310"]

#define getJsonMessage(error) ([error respondsToSelector:@selector(objectForKey:)]?[error objectForKey:@"message"]:nil)

//#define getJsonErrorCode(error) ([error respondsToSelector:@selector(objectForKey:)]?[error objectForKey:@"message"]:nil)

#define darkerBackGroundColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-block1-repeat"]]


#define iconImageURL(orgurl)  [NSString stringWithFormat:@"%@?imageView/1/w/90/h/90", orgurl]
#define char2String(str) [NSString stringWithCString:str encoding:NSUTF8StringEncoding]
#define int2str(intVal) [NSString stringWithFormat:@"%i",intVal]
#define float2str(fVal) [NSString stringWithFormat:@"%f",fVal]
#define str2json(str) [EZNetworkUtility str2json:str]
#define currentLoginID  [[EZDataUtil getInstance] getCurrentPersonID]
#define uid2person(uid) [[EZUserUtil getInstance] id2user:uid]
#define currentLoginUser [EZDataUtil getInstance].currentLoginPerson
#define str2url(strs) [NSURL URLWithString:strs]
#define url2fullpath(url) [EZFileUtil fileURLToFullPath:url]

#define fileurl2image(url) [UIImage imageWithContentsOfFile:url2fullpath(url)]
#define radians(degree) degree*M_PI/180
#define str2cover(str) [[EZUserUtil getInstance] getCoverURL:str]
#define file2url(filename) [[NSURL fileURLWithPath:filename] absoluteString]

//Color for the name
//So wherever I have the name I will use this macro. to simplify the things
#define namecolor [UIColor colorFromHex:@"1e72c8"]

#define cellGray  [UIColor colorFromHex:@"dfdfdf"]

#define GrayTextColor [UIColor colorFromHex:@"9d9d9c"]

#define setnav(nav) [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg-navigationBar"] forBarMetrics:UIBarMetricsDefault]

#define setBackground(vw) vw.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-contentsBackground"]]

#define contentBackground  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-contentsBackground"]]

#define imgview(filename)  [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]]
#define str2img(filename)   [UIImage imageNamed:filename]

//#define barbutton(img1, img2)


#define headholder [UIImage imageNamed:@"head_holder"]

#define colorFromD(colorStr) [UIColor colorFromDecimal:colorStr]

#define colorFromH(colorStr) [UIColor colorFromHex:colorStr]

//When the image are downloading, we will use this image as place holder
#define imageholder [UIImage imageNamed:@"head_holder"]

#define CoreDBModel @"FeatherCV"


#define ClientDB @"feather.sqllite"

//How many size I will query for each time
//The magic number have cost me many time. 
#define NoticeQuerySize 20;


#define EZLikeString @":like"

#define CameraFilterReady @"CameraFilterReady"

#define TokenEventName @"RegisterToken"

#define RecievedMessage @"RecievedMessage"

#define RecievedNotice @"RecievedNotice"

#define ApplicationQuit @"ApplicationQuit"

#define LoadedUser @"LoadedUser"

#define LoginEvent @"LoginEvent"

//Mean people ask me to be a login page.
#define EventTransferToLogin @"EventTransferToLogin"

#define EventTransferToRegister @"EventTransferToRegister"

#define EventKeyboardWillHide @"EventKeyboardWillHide"

#define EventKeyboardDidHide @"EventKeyboardDidHide"

#define EventKeyboardWillRaise @"EventKeyboardWillRaise"

#define EventKeyboardDidRaise @"EventKeyboardDidRaise"

//This event will called when user information get updated. 
#define EZEventUserInfoUpdate @"EZEventUserInfoUpdate"

//The returned the value will be the login status.
//If you didn't get valid login ID, then time to check the login Error details

//#define LoginSuccess @"LoginSuccess"

//Only have one event for login block
//We need to check the currentUserID to make sure we really really
//successfully login.
#define LoginCompleted @"LoginCompleted"


#define EZNotificationEvent @"EZNotificationEvent"
//#define LoginCancel @"LoginCancel"

//Weibo event
//Both login and logout and cancel will use this
//The reason is that, I will use the EZMessageCenter
//If i use different block, I would have to clean them
//So why not just use one block. 
#define WeiboLoginEvent @"WeiboLoginEvent"

#define WeiboLogoutEvent @"WeiboLogoutEvent"

//Will trigger this event when customer select an extra people into current p2p session
#define PresentNewGroup @"PresentNewGroup"

//We can ask the ApplicationDelegate to switch the tabs
#define TabSwitchEvent @"TabSwitchEvent"

//Whenever I recieved a group operation notification
#define RecievedGroupOperation @"RecievedGroupOperation"

//This event is used to dectect a touch on the whole screen
//without affect the normal logic
#define GlobalTapped @"GlobalTapped"


#define DeviceTokenKey @"DeviceTokenKey"

//The purpose of this event is to decrease the session unread messge count
//I love this. 
#define DecreaseMessageCount @"DecreaseMessageCount"

#define EZReachabilityEvent @"EZReachabilityEvent"

//This is used, because I create the group before the creation call is successful,
//So i need a way so that user could send the message out even before the group remote returned.
//Yes, let's enjoy and test it.
//Time to cultivate your mindset for things like this.
#define EZGroupCreated @"EZGroupCreated"

#define RecievedSelfMessage @"RecievedSelfMessage"

#define EZRemoveSession @"EZRemoveSession"

#define EZRecievedSessionID @"EZRecievedSessionID"

#define HTTPMethodPUT @"PUT"

#define HTTPMethodDelete @"DELETE"


//For some code need to execute periodically.
#define TimerEvent @"TimerEvent"
#define DefaultTimerPeriod 60

#define weiboAvatar [[EZWeiboUtil getInstance].userInfo objectForKey:@"profile_image_url"]

#define oathWeibo @"weibo"

#define oathQQ @"QQ"

#define oathWeixin @"weixin"

#define weiboUID  [EZWeiboUtil getInstance].weibo.userID

#define weiboAccessToken  [EZWeiboUtil getInstance].weibo.accessToken

#define weiboExpiredDate  [EZWeiboUtil getInstance].weibo.expirationDate

#define weiboNickname [[EZWeiboUtil getInstance].userInfo objectForKey:@"name"]

#define serviceURL @"http://api.liangne.com/v1"
//#define serviceURL @"http://www.songeast.com.cn/statusnet/index.php/mobile"
#define serverHost @"api.liangne.com"

//This is used to get the cookie out.
#define serverHostURL @"http://api.liangne.com"

//#define serviceURL @"http://192.168.1.123:3000/mobile"
//#define serviceURL @"http://192.168.1.122/statusnet/index.php/mobile"

#define CurrentUser @"CurrentUser"

//Determine if we have ever login in this device
#define EverLoginKey @"EverLoginKey"

//Later only change one place can get all the functionality
#define PlatFormString @"mobile"

#define isEverLoginDevice [[EZUserUtil getInstance] isEverLogin]

#define cleanEverLoginDevice [[EZUserUtil getInstance] cleanEverLogin]

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#ifdef DEBUG
#define EZCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
EZDEBUG(xx, ##__VA_ARGS__); \
} \
} ((void)0)
#else
#define EZCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG


#ifdef DEBUG
#define EZDEBUG(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define EZDEBUG(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

#endif
