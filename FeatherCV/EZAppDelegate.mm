//
//  EZAppDelegate.m
//  FeatherCV
//
//  Created by xietian on 13-11-21.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <GPUImage.h>
#import "EZAppDelegate.h"
#import "EZFaceTestPage.h"
#import "EZCombinedPhoto.h"
#import "EZPhoto.h"
#import "EZFileUtil.h"
#import "EZConversation.h"
#import "EZPerson.h"
#import "EZUIUtility.h"
#import "EZMessageCenter.h"
#import "EZDataUtil.h"
#import "EZAlbumTablePage.h"
#import "EZScrollContainer.h"
#import "EZDisplayPhoto.h"
#import "EZStyleImage.h"
#import "EZTestSuites.h"
#import "EZViewContainer.h"
#import "EZTiltMainView.h"
#import "EZContactsPage.h"
#import "EZMainPage.h"
#import "DLCImagePickerController.h"
#import "EZContactTablePage.h"
#import "ILTranslucentView.h"
#import "EZUIUtility.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "LFDisplayBridge.h"
#import "EZAnimationUtil.h"
#import "EZKeyboadUtility.h"
#import "UIImageView+AFNetworking.h"
#import "EZCoreAccessor.h"
#import "EZNote.h"


@implementation EZAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSMutableArray*) createPersons
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(int i = 0; i < 20; i++){
        EZPerson* person = [[EZPerson alloc] init];
        person.name = [NSString stringWithFormat:@"天哥:%i", i];
        person.avatar = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
        [res addObject:person];
    }
    return res;
}

//Test the refresh functionality.
- (BOOL) animate
{
    EZDEBUG(@"Refresh once");
    return TRUE;
}

- (void)orientationChanged:(NSNotification *)notification
{
    EZDEBUG(@"Orientation changed:%i", [UIDevice currentDevice].orientation);
    _previousOrientation = [UIDevice currentDevice].orientation;
    //[self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if(([UIDevice currentDevice].orientation ==  UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)){
        EZDEBUG(@"Will raise camera");
        
        dispatch_later(0.2, ^(){
            if(_previousOrientation == UIDeviceOrientationLandscapeLeft || _previousOrientation == UIDeviceOrientationLandscapeRight){
                [[EZMessageCenter getInstance] postEvent:EZPositionHold attached:@(_previousOrientation)];
            }
        });
        //[[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:nil];
    }
    
    if(([UIDevice currentDevice].orientation ==  UIDeviceOrientationPortrait)){
        EZDEBUG(@"Back to portrait");
        /**
        dispatch_later(0.2, ^(){
            if(_previousOrientation == UIDeviceOrientationPortrait){
                [[EZMessageCenter getInstance] postEvent:EZPositionHold attached:@(_previousOrientation)];
            }
        });
         **/
        //[[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:nil];
    }
    
}


- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void) setupEvent
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsReady:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
}

//Cool, I could have better effects now.
- (void)cameraIsReady:(NSNotification *)notification
{
    NSLog(@"Camera is ready...");
    [[EZMessageCenter getInstance] postEvent:EZCameraIsReady attached:nil direct:NO];
    // Whatever
}


- (UIViewController*) createTimelineView
{
    return nil;
}

- (UIViewController*) createScrollView
{
    [self setupEvent];
    NSString* currentPersonID = [EZDataUtil getInstance].currentPersonID;
    EZDEBUG(@"Current personID:%@", currentPersonID);
    EZQueryBlock qb = ^(NSInteger start, NSInteger limit, EZEventBlock success, EZEventBlock failure){
        [[EZDataUtil getInstance] loadAlbumPhoto:start limit:limit success:success failure:failure];
    };
   
    EZAlbumTablePage* albumPage = [[EZAlbumTablePage alloc] initWithQueryBlock:qb];
    UINavigationController* mainNav = [[UINavigationController alloc] initWithRootViewController:albumPage];
    EZDEBUG(@"original status bar style:%i, navigationBar style:%i, %@", [UIApplication sharedApplication].statusBarStyle, mainNav.navigationBar.barStyle, mainNav.navigationBar.barTintColor);
    EZUIUtility.sharedEZUIUtility.showMenuItems =[[NSMutableArray alloc] initWithArray:@[
    @{@"text":@"朋友",
    @"block":^(id obj){
        EZDEBUG(@"Friend get clicked");
        EZContactTablePage* contactPage = [[EZContactTablePage alloc] init];
        [mainNav pushViewController:contactPage animated:YES];
        
        
    }},
    @{@"text":@"最近的",
    @"block":^(id obj){
        //EZDEBUG(@"Switch to recent");
        //UIImageView* blurView = [[UIImageView alloc] initWithFrame:albumPage.view.frame];
        //blurView.image = [[albumPage.view contentAsImage] applyBlurWithRadius:18.0 tintColor:RGBA(220, 220, 220, 100) saturationDeltaFactor:0.5 maskImage:nil];
        //blurView.image = [[albumPage.view contentAsImage] createCIBlurImage:20.0];
        //blurView.backgroundColor = [UIColor redColor];
        [LFDisplayBridge sharedInstance].pauseProcess = ![LFDisplayBridge sharedInstance].pauseProcess;
        EZDEBUG(@"Current value:%i", [LFDisplayBridge sharedInstance].pauseProcess);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            LFGlassView* lglass = [[LFGlassView alloc] initWithFrame:CGRectMake(20, 200, 150, 150)];
            lglass.blurRadius = 5.0;
            lglass.backgroundColor = RGBA(100, 100, 100, 100);
            [TopView addSubview:lglass];
        });
        
        //[albumPage.view insertSubview:lglass atIndex:0];
        //
        
        //EZDEBUG(@"image size:%@, frame:%@, view:%@", NSStringFromCGSize(blurView.image.size), NSStringFromCGRect(albumPage.view.frame), NSStringFromCGRect(albumPage.view.frame));
        //[TopView addSubview:blurView];
    }
    }]];
    EZDEBUG(@"Translucent is:%i, bar style default:%i", mainNav.navigationBar.translucent, mainNav.navigationBar.barStyle);
  
 
    [[EZMessageCenter getInstance] registerEvent:EZCameraCompleted block:^(UIImage* img){
        EZDEBUG(@"I will slide the image back");
        //[scrollContainer setIndex:1 animated:YES slide:YES];
        if(img){
            //[[EZDataUtil getInstance] saveImage:img success:^(ALAsset* asset){
            
                EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                ed.isFront = true;
                EZPhoto* ep = [[EZPhoto alloc] init];
                //ed.pid = ++photoCount;
                //ep.asset = asset;
                ep.isLocal = true;
                ep.assetURL = [EZFileUtil saveImageToDocument:img];
                ed.photo = ep;
                //EZDEBUG(@"Before size");
                ep.size = img.size;//[asset defaultRepresentation].dimensions;
                [albumPage addPhoto:ed];
                //[coverImage setImage:[[asset defaultRepresentation] fullScreenImage]];
            //} failure:^(NSError* err){
            //    EZDEBUG(@"Error:%@", err);
            //}];
        }
    }];
    
    
    //[[EZDataUtil getInstance] readAlbumInBackground:5 limit:5];
    
    //dispatch_later(10.0, ^(){
        //[[EZDataUtil getInstance] loadPhotoBooks];
    //});
    return mainNav;
    //return homeNavigationBar;
    
}

- (void) setupAppearance
{
    //Remove the drop shadow
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //[[UINavigationBar appearance] set]
    //[[UINavigationBar appearance] setBarTintColor:RGBCOLOR(0, 197, 213)];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    //UIImage *gradientImage44 =
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:ClearBarImage forBarMetrics:UIBarMetricsDefault];
    [[UIScrollView appearance] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14.0]];
    //[[UINavigationBar appearance] setBackgroundImage:ClearBarImage forBarMetrics:UIBarMetricsLandscapePhone];
    //[[UINavigationBar]]
    
    /**
    [[EZMessageCenter getInstance] registerEvent:EZStatusBarChange block:^(NSNumber* status){
        EZDEBUG(@"Status bar changed:%i", status.intValue);
        if(status.intValue == 1){
            [EZDataUtil getInstance].barBackground.alpha = 0;
        }else{
            [EZDataUtil getInstance].barBackground.alpha = 1;
        }
    }];
     **/
    /**
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSForegroundColorAttributeName,
      //[UIFont fontWithName:@"Arial-Bold" size:0.0],
      //NSFontAttributeName,
      nil]];
     **/
    // //replace "nil" with your method to programmatically create a UIImage object with transparent colors for portrait orientation
    //UIImage *gradientImage32 = [UIImage imageWithColor:RGBA(0, 0, 0, 128)]; //replace "nil" with your method to programmatically create a UIImage object with transparent colors for landscape orientation
    //mainNav.navigationBar.hidden = true;
    //[[UINavigationBar appearance]]
    //customize the appearance of UINavigationBar
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
    //[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

- (void) setupKeyboard
{
    //Setup the keyBoard, then I could monitoring the whole thing
    [EZKeyboadUtility getInstance];
}

- (void) setupNetwork
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
   
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[EZDataUtil getInstance] setupNetworkMonitor];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(uploadPendingImages:)
                                   userInfo:nil
                                    repeats:YES];
    //[EZDataUtil getInstance].currentPersonID = @"coolguyMobile";
}

- (void) setupRecieveNotification
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    EZDEBUG(@"enabled type:%i", enabledTypes);
}


//isLive mean if we recieved from the foreground or from the background
- (void) handleNotification:(NSDictionary*)dict isLive:(BOOL)isLive
{
    //[UIApplication sharedApplication].applicationIconBadgeNumber += [[dict objectForKey:@"badge"] integerValue];
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //EZNote* mockNote = [EZNote alloc]
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    EZDEBUG(@"Notification is alive:%i", isLive);
    //EZNote* mockNote = [[EZNote alloc] init];
    NSString* noteID = [dict objectForKey:@"noteID"];
    if(!isLive){
        if(![[EZDataUtil getInstance].pushNotes objectForKey:noteID]){
            [[EZDataUtil getInstance].pushNotes setObject:@"" forKey:noteID];
        }
        [[EZDataUtil getInstance] queryNotify];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    //How to trigger the token ID upload? I can store my TokenID to the NSUserDefaults
    //So when the token ID is comming, I could upload it.
    //Let's design the mechanism.
    //NSInteger currentID = 1;//[EZUserUtil getInstance].getCurrentUser.profile_id;
    //NSInteger loginID = currentLoginID;
    
    [[NSUserDefaults standardUserDefaults] setValue:hexToken forKey:DeviceTokenKey];
    
    
    EZDEBUG(@"Push notificatin id:%@", hexToken);
}

- (void) uploadPendingImages:(id)obj
{
    if(currentLoginID){
        if(![EZDataUtil getInstance].networkAvailable){
            EZDEBUG(@"quit for network not available");
            return;
        }
        [[EZDataUtil getInstance] uploadPendingPhoto];
        [[EZDataUtil getInstance] queryPendingPerson];
        //[[EZDataUtil getInstance] storeAll];
        if([EZDataUtil getInstance].timerBlock){
            [EZDataUtil getInstance].timerBlock(nil);
        }
        [[EZDataUtil getInstance] queryNotify];
    
    
        BOOL uploaded = [[NSUserDefaults standardUserDefaults] boolForKey:EZTokenUploaded];
        if(!uploaded){
            EZDEBUG(@"try to upload token");
            NSString* token = [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
            if(token){
                [[EZDataUtil getInstance] updatePerson:@{@"pushToken":token} success:^(id obj){
                    EZDEBUG(@"upload the token success:%@", currentLoginID);
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:EZTokenUploaded];
                } failure:^(id err){
                    EZDEBUG(@"upload token failed, will try later:%@", err);
                }];
            }else{
                
            }
        }
    }
    /**
    static int count = 1;
    ++count;
    NSMutableArray* persons = [[NSMutableArray alloc] init];
    [persons addObjectsFromArray:[[EZDataUtil getInstance].currentQueryUsers allValues]];
     //EZDEBUG(@"Will store %i persons", persons.count);
        //[persons addObjectsFromArray:[[EZDataUtil getInstance].notJoinedUsers allObjects]];
    [[EZDataUtil getInstance] storeAllPersons:persons];
     **/
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    EZDEBUG(@"Recieved message:%@, %@, current badge number:%i, state:%i", userInfo, [userInfo objectForKey:@"alert"], [UIApplication sharedApplication].applicationIconBadgeNumber, application.applicationState);
    if ( application.applicationState == UIApplicationStateActive ){
        [self handleNotification:userInfo isLive:YES];
    }else{
        [self handleNotification:userInfo isLive:NO];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _cameraRaised = false;
    ///[EZDataUtil getInstance].currentPersonID = @"52f783d7e7b5b9dd9c28f1cc";
    [MobClick startWithAppkey:@"5350f11d56240bb1e901071a" reportPolicy:SENDWIFIONLY   channelId:@"AppStore"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    EZDEBUG(@"Mobile version:%@", version);
    [MobClick setAppVersion:version];
    [MobClick beginEvent:EZALStartPeriod label:@"launch"];
    [EZTestSuites testAll];
    [self setupRecieveNotification];
    
    NSDictionary *remoteNote =  [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    EZDEBUG(@"Launched options:%@", remoteNote);
    if(remoteNote){
        [self handleNotification:remoteNote isLive:NO];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    //NSString* thumb = url2thumb(@"http://cool.guy/cool.jpg");
    //EZDEBUG(@"The thumb url is:%@", thumb);
    //CFTimeInterval startTime = CACurrentMediaTime();
    //perform some action
    //EZDEBUG(@"first value:%f", startTime);
    //CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //EZDEBUG(@"elipsed time:%f", elapsedTime);
    
    /**
    [[EZDataUtil getInstance] loginUser:@{
                                          @"mobile":@"15216727142",
                                          @"password":@"i love you"
                                          } success:^(EZPerson* ps){
                                              EZDEBUG(@"login success");
                                          } error:^(NSError* err){
                                          }];
    **/
    //[EZDataUtil getInstance].currentPersonID = nil;
    //[EZDataUtil getInstance].currentPersonID = @"5325944f21ae7a427d586ae7";
    //[EZDataUtil getInstance].currentPersonID = @"532585b321ae7a2e53522fa0";
    //[EZDataUtil getInstance].currentPersonID = @"531e7cd5e7b5b9f911342692";
    //EZDEBUG("Fonts %@", [UIFont familyNames]);
    
    //[EZCoreAccessor cleanClientDB];
    EZDEBUG(@"login info:%@", [[EZDataUtil getInstance] getCurrentPersonID]);
    if(![[EZDataUtil getInstance] getCurrentPersonID]){
        [[EZDataUtil getInstance]cleanAllLoginInfo];
        dispatch_later(0.1, ^(){
            [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){
                [[EZDataUtil getInstance] getMatchUsers:nil failure:nil];
            } failure:^(id err){} reason:@"请注册" isLogin:NO];
        });
    }else{
        [[EZDataUtil getInstance] loadAllPersons];
        [[EZDataUtil getInstance] getMatchUsers:^(id obj){
            EZDEBUG(@"Will setup notes");
            [[EZMessageCenter getInstance] postEvent:EZNoteCountSet attached:nil];
        } failure:nil];
    }
    //[[EZAnimationUtil sharedEZAnimationUtil] addAnimation:self];
    
    [self setupAppearance];
    [self setupNetwork];
    //[self enableProximate:YES];
    [self setupKeyboard];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //self.window.backgroundColor = [UIColor greenColor];
    //[[EZDataUtil getInstance] loadAlbumPhoto:0 limit:100 success:^(NSArray* phs){
    //    EZDEBUG(@"returned size:%i", phs.count);
    //} failure:^(NSError* err){
    //    EZDEBUG(@"err:%@", err);
    //}];
    EZDEBUG(@"before get scrollView");
    EZUIUtility.sharedEZUIUtility.mainWindow = self.window;
    self.window.rootViewController = [self createScrollView];
    //EZDEBUG(@"After get scrollView");
   
    EZDEBUG(@"Register orientation change");
    //[self.window addSubview:barView];
    /**
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        EZDEBUG(@"I would like to bring barView to front");
        [self.window bringSubviewToFront:barView];
    });
     **/
    [self.window makeKeyAndVisible];
    EZDEBUG(@"Visible enabled");
    return YES;
}

- (BOOL)applicationTestFace:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //cv::Mat mat;
    //GPUImageFilter* fg = [[GPUImageFilter alloc] init];
    EZFaceTestPage* ft = [[EZFaceTestPage alloc] init];
    self.window.rootViewController = ft;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EZDataUtil getInstance] storePendingPhoto];
    [[EZCoreAccessor getClientAccessor] saveContext];
    [MobClick endEvent:EZALStartPeriod label:@"enterBackground"];
    EZDEBUG(@"Will enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [MobClick beginEvent:EZALStartPeriod label:@"enterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //[MobClick event:EZALStartPeriod label:@"start"];
    EZDEBUG(@"Become active");
    [[EZDataUtil getInstance] queryNotify];
    [[EZMessageCenter getInstance] postEvent:EZAlbumImageUpdate attached:nil];
    [MobClick beginEvent:EZALStartPeriod label:@"becomeActive"];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    EZDEBUG(@"Will terminate");
    //[MobClick event:EZALStartPeriod label:@"end"];
    [MobClick endEvent:EZALStartPeriod label:@"terminate"];
    //[[EZDataUtil getInstance] storePendingPhoto];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FeatherCV" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FeatherCV.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




@end
