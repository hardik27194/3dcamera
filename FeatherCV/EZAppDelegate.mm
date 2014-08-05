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
#import "EZDummyPage.h"
#import "EZLoginController.h"
#import "EZRegisterCtrl.h"
#import "FaceppAPI.h"
#import "EZContactMain.h"
#import "EZPinchController.h"
#import "EZPhotoDetail.h"
#import "CKCalendarView.h"
#import "CKViewController.h"
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


- (void) setupAppearance
{
    //Remove the drop shadow
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:17]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //[[UINavigationBar appearance] set]
    //[[UINavigationBar appearance] setBarTintColor:RGBCOLOR(0, 197, 213)];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    //UIImage *gradientImage44 =
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //[[UINavigationBar appearance] setBackgroundImage:ClearBarImage forBarMetrics:UIBarMetricsDefault];
    [[UIScrollView appearance] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14.0]];
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
    
    /**
    if(currentLoginID){
        if(![EZDataUtil getInstance].networkAvailable){
            EZDEBUG(@"quit for network not available");
            return;
        }
        _queryCount ++;
        [[EZDataUtil getInstance] uploadPendingPhoto];
        [[EZDataUtil getInstance] queryPendingPerson];
        //if((_queryCount % 5) == 0){
        [[EZDataUtil getInstance] removeExpiredPhotos];
        //}
        //[[EZDataUtil getInstance] storeAll];
        if([EZDataUtil getInstance].timerBlock){
            [EZDataUtil getInstance].timerBlock(nil);
        }
        [[EZDataUtil getInstance] queryNotify];
        [[EZDataUtil getInstance] uploadAvatar];
    
    
        BOOL uploaded = [[NSUserDefaults standardUserDefaults] boolForKey:EZTokenUploaded];
        if(!uploaded){
            EZDEBUG(@"try to upload token");
            NSString* token = [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
            if(token){
                [[EZDataUtil getInstance] updatePerson:@{@"pushToken":token, @"prodFlag":EZProductFlag} success:^(id obj){
                    EZDEBUG(@"upload the token success:%@", currentLoginID);
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:EZTokenUploaded];
                } failure:^(id err){
                    EZDEBUG(@"upload token failed, will try later:%@", err);
                }];
            }else{
                
            }
        }
    }
     
     **/
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



- (void) listAllFonts
{
    NSArray *fontFamilyNames = [UIFont familyNames];
    
    // loop
    for (NSString *familyName in fontFamilyNames)
    {
        EZDEBUG(@"Font Family Name = %@", familyName);
        
        // font names under family
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        
        //NSLog(@"Font Names = %@", names);
        for(NSString* fontName in names){
            EZDEBUG(@"Font name:%@", fontName);
        }
        
        // add to array
        //[fontNames addObjectsFromArray:names];
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _cameraRaised = false;
    ///[EZDataUtil getInstance].currentPersonID = @"52f783d7e7b5b9dd9c28f1cc";
    [MobClick startWithAppkey:@"5350f11d56240bb1e901071a" reportPolicy:SENDWIFIONLY channelId:@"AppStore"];
    [FaceppAPI initWithApiKey:@"80554f973e57498ae065ec46d16c6e6a" andApiSecret: @"7pwPTvUY2wSf0FqYI7WbZ783U3l0MPNJ" andRegion:APIServerRegionCN];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    EZDEBUG(@"Mobile version:%@", version);
    [MobClick setAppVersion:version];
    [MobClick beginEvent:EZALStartPeriod label:@"launch"];
    [EZTestSuites testAll];
    [self setupRecieveNotification];
    //[self listAllFonts];
    NSDictionary *remoteNote =  [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    EZDEBUG(@"Launched options:%@", remoteNote);
    if(remoteNote){
        [self handleNotification:remoteNote isLive:NO];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    EZDEBUG(@"login info:%@", [[EZDataUtil getInstance] getCurrentPersonID]);
    [[EZDataUtil getInstance] setCurrentPersonID:nil];
    if(![[EZDataUtil getInstance] getCurrentPersonID]){
        [[EZDataUtil getInstance]cleanAllLoginInfo];
        dispatch_later(0.1, ^(){
            [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){
                [[EZDataUtil getInstance] getMatchUsers:nil failure:nil];
            } failure:^(id err){} reason:@"请注册" isLogin:YES];
        });
    }else{
        [[EZDataUtil getInstance] loadAllPersons];
        [[EZDataUtil getInstance] getMatchUsers:^(id obj){
            EZDEBUG(@"Will setup notes");
            [[EZMessageCenter getInstance] postEvent:EZNoteCountSet attached:nil];
        } failure:nil];
    }
    
    [self setupAppearance];
    [self setupNetwork];
    //[self enableProximate:YES];
    //[self setupKeyboard];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //self.window.backgroundColor = //[UIColor greenColor];
    //[[EZDataUtil getInstance] loadAlbumPhoto:0 limit:100 success:^(NSArray* phs){
    //    EZDEBUG(@"returned size:%i", phs.count);
    //} failure:^(NSError* err){
    //    EZDEBUG(@"err:%@", err);
    //}];
    EZDEBUG(@"before get scrollView");
    EZUIUtility.sharedEZUIUtility.mainWindow = self.window;
    //[self createPersonMain:self.window];
    //self.window.rootViewController = [self createScrollView];
    //EZDEBUG(@"After get scrollView");
    self.window.rootViewController = [self createMainPage];
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

- (UINavigationController*) createMainPage
{
    
    //TKCalendarMonthTableViewController* calendar = [[TKCalendarMonthTableViewController alloc] initWithSunday:YES];
    
    EZMainPage* mainPage = [[EZMainPage alloc] init];
    //EZCalendarPicker* cp = [[EZCalendarPicker alloc] init];
    //CKViewController* ck = [[CKViewController alloc] init];
    UINavigationController* rootNav = [[UINavigationController alloc] initWithRootViewController:mainPage];
    return rootNav;
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:EZNotFirstTime]){
        [[EZMessageCenter getInstance] postEvent:EZAlbumImageUpdate attached:nil];
    }
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:EZNotFirstTime];
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
    //[self saveContext];
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
