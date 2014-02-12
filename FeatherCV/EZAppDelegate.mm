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

- (void)orientationChanged:(NSNotification *)notification
{
    EZDEBUG(@"Orientation changed:%i", [UIDevice currentDevice].orientation);
    //[self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if(([UIDevice currentDevice].orientation ==  UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)){
        EZDEBUG(@"Will raise camera");
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
    NSString* currentPersonID = [[EZDataUtil getInstance] getCurrentPersonID];
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
            [[EZDataUtil getInstance] saveImage:img success:^(ALAsset* asset){
                EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                ed.isFront = true;
                EZPhoto* ep = [[EZPhoto alloc] init];
                //ed.pid = ++photoCount;
                ep.asset = asset;
                ep.isLocal = true;
                ed.photo = ep;
                //EZDEBUG(@"Before size");
                ep.size = [asset defaultRepresentation].dimensions;
                [albumPage addPhoto:ed];
                //[coverImage setImage:[[asset defaultRepresentation] fullScreenImage]];
            } failure:^(NSError* err){
                EZDEBUG(@"Error:%@", err);
            }];
        }
    }];
    
    
    [[EZDataUtil getInstance] readAlbumInBackground:5 limit:5];
    [[EZDataUtil getInstance] loadPhotoBooks];
    return mainNav;
    //return homeNavigationBar;
    
}

- (void) setupAppearance
{
    //Remove the drop shadow
    //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    //UIImage *gradientImage44 = [UIImage imageWithColor:RGBA(0, 0, 0, 128)]; //replace "nil" with your method to programmatically create a UIImage object with transparent colors for portrait orientation
    //UIImage *gradientImage32 = [UIImage imageWithColor:RGBA(0, 0, 0, 128)]; //replace "nil" with your method to programmatically create a UIImage object with transparent colors for landscape orientation
    //mainNav.navigationBar.hidden = true;
    //[[UINavigationBar appearance]]
    //customize the appearance of UINavigationBar
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
    //[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

- (void) setupNetwork
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //EZDEBUG(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        EZDEBUG(@"network status:%i", status);
    }];
    [EZDataUtil getInstance].currentPersonID = @"coolguyMobile";
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _cameraRaised = false;
    [EZTestSuites testAll];
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
    if(![EZDataUtil getInstance].currentPersonID){
        [[EZDataUtil getInstance] registerUser:@{
                            @"mobile":int2str(rand()),
                            @"password":@"coolguy",
                            @"name":@"coolguy"
                            } success:^(EZPerson* ps){
                                EZDEBUG(@"successfully registerred:%@, personID:%@", ps.mobile, ps.personID);
                            } error:^(id err){
                                EZDEBUG(@"Error detail:%@", err);
                            }];
    }
    [self setupAppearance];
    [self setupNetwork];
    [self enableProximate:YES];
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
    EZDEBUG(@"After get scrollView");
   
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

- (void)proximityStateChanged:(NSNotification *)note
{
    if ( !note ) {
        //[self setFaceDownOnSurface:NO];
        EZDEBUG(@"Don't have notes");
        //return;
    }else{
        EZDEBUG(@"notes name:%@, user information:%@", note.name, note.userInfo);
    }
    
    UIDevice *device = [UIDevice currentDevice];
    //BOOL newProximityState = device.proximityState;
    EZDEBUG(@"state is:%i", device.proximityState);
    if(device.proximityState == 0){
        [[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:nil];
        [[EZMessageCenter getInstance] postEvent:EZFaceCovered attached:@(0)];
    }
}

- (void) enableProximate:(BOOL)enable
{
    UIDevice *device = [UIDevice currentDevice];
    if ( enable ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        device.proximityMonitoringEnabled = YES;
    } else {
        device.proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
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
