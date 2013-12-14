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
#import "EZAlbumCollectionPage.h"
#import "EZContactsPage.h"
#import "EZMainPage.h"
#import "DLCImagePickerController.h"
#import "EZContactTablePage.h"


@implementation EZAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (EZCombinedPhoto*) generatedCombinedDummy:(NSString*)myName friend:(NSString*)friendName
{
    EZCombinedPhoto* res = [[EZCombinedPhoto alloc] init];
    EZPhoto* ep = [[EZPhoto alloc] init];
    ep.url = [EZFileUtil fileToURL:@"img01.jpg"].absoluteString;
    ep.ownerID = 1;
    
    EZPhoto* ep2 = [[EZPhoto alloc] init];
    ep2.url = [EZFileUtil fileToURL:@"img02.jpg"].absoluteString;
    
    res.selfPhoto = ep;
    res.otherPhoto = ep2;
    EZConversation* conv = [[EZConversation alloc] init];
    conv.content = @"我爱好照片";
    conv.conversationID = 10;
    conv.createdTime = [NSDate date];
    //res.conversations = @[conv];
    return res;
}


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
//This method only for test purpose,
//so that I can move ahead. Just decouple with your environment and move as fast as you can.
//Enjoy, coding can make you happy, why do you keep yourself from doing this for so long a time?
- (NSArray*) getDummyPhotos
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    //EZCombinedPhoto* cp = [[EZCombinedPhoto alloc] init];
    for(int i = 0; i < 100; i++){
        [res addObject:[self generatedCombinedDummy:@"dummy1" friend:@"dummy2"]];
    }
    return res;
}

- (void)orientationChanged:(NSNotification *)notification
{
    EZDEBUG(@"Orientation changed:%i", [UIDevice currentDevice].orientation);
    //[self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if(([UIDevice currentDevice].orientation ==  UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)){
        EZDEBUG(@"Will raise camera");
        
        //_cameraRaised = true;
        /**
        [[EZUIUtility sharedEZUIUtility] raiseCamera:NO controller:[self topViewController] completed:^(UIImage* image){
            [[EZDataUtil getInstance] uploadPhoto:image success:^(EZCombinedPhoto* cp){
                EZDEBUG(@"Upload photo success");
                [[EZMessageCenter getInstance] postEvent:EZPhotoUploadSuccess attached:cp];
            } failure:^(id error){
                EZDEBUG("Upload photo failed");
            }];
            
            EZDEBUG(@"Get photo image");
        }];
         **/
        
    }//EZDEBUG(@"Rotation is:%i", [UIDevice currentDevice].orientation);
    
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

- (EZScrollContainer*) createScrollView
{
    [self setupEvent];
    EZScrollContainer* scrollContainer = [[EZScrollContainer alloc] initWithNibName:Nil bundle:nil];
    //UIViewController* v1 = [[UIViewController alloc] init];
    //v1.view.backgroundColor = [UIColor greenColor];
    EZContactTablePage* contactPage = [[EZContactTablePage alloc] initWithStyle:UITableViewStylePlain];
    //[contactPage reloadPersons];
    UINavigationController* contactNav = [[UINavigationController alloc] initWithRootViewController:contactPage];
    //UIViewController* v2 = [[UIViewController alloc] init];
    //v2.view.backgroundColor = [UIColor yellowColor];
    //EZFaceDetector* fd = [[EZFaceDetector alloc] init];
    
    int currentPerson = [[EZDataUtil getInstance] getCurrentPersonID];
    EZDEBUG(@"Current personID:%i", currentPerson);
    EZQueryBlock qb = ^(int start, int limit, EZEventBlock success, EZEventBlock failure){
        //[[EZDataUtil getInstance] loadAlbumPhoto:start limit:limit success:success failure:failure];
    };
    //EZAlbumCollectionPage* albumPage = [EZAlbumCollectionPage createGridAlbumPage:true ownID:currentPerson queryBlock:qb];
    EZAlbumTablePage* albumPage = [[EZAlbumTablePage alloc] initWithQueryBlock:qb];
    UIViewController* dummyPage = [[UIViewController alloc] init];
    
    //albumPage.queryBlock = qb;
    UINavigationController* mainNav = [[UINavigationController alloc] initWithRootViewController:albumPage];
    
    UIViewController* v3 = [[UIViewController alloc] init];
    //v3.view.backgroundColor = [UIColor redColor];
    
    EZStyleImage* coverImage = [EZStyleImage createBlurredImage:CGRectMake(0, 69, 320, 428)];
    //Will use the white image as cover
    [coverImage setImage:[UIImage imageNamed:@"img01.jpg"]];
    //cv::Mat mat = [EZImageConverter cvMatFromUIImage:[UIImage imageNamed:@"img01.jpg"]];
    //EZDEBUG(@"The image row:%i, col:%i", mat.rows, mat.cols);
    [v3.view addSubview:coverImage];
    
    [[EZMessageCenter getInstance] registerEvent:EZCoverImageChange block:^(UIImage* img){
        [coverImage setImage:img];
    }];
    
    //When will this get called?
    //When the orientation changed. Let's try to get the camera
    [[EZMessageCenter getInstance] registerEvent:EZTriggerCamera block:^(id obj){
        [scrollContainer setIndex:2 animated:NO slide:NO];
    }];
    
    //UIImagePickerController* picker = [[EZUIUtility sharedEZUIUtility] getCamera:NO completed:^(UIImage* img){
    //    EZDEBUG(@"Picked an image");
    //}];
    //[scrollContainer addViewController:v1];
    //[scrollContainer addViewController:v2];
    //[scrollContainer addViewController:v3];
    //EZDEBUG(@"view pointer:%i", (int)scrollContainer.view);
    [scrollContainer addChildren:@[contactNav, dummyPage, v3]];
    scrollContainer.currentIndex = 1;
    
    [[EZMessageCenter getInstance] registerEvent:EZCameraCompleted block:^(UIImage* img){
        EZDEBUG(@"I will slide the image back");
        [scrollContainer setIndex:1 animated:YES slide:YES];
        if(img){
            [[EZDataUtil getInstance] saveImage:img success:^(ALAsset* asset){
                EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                ed.isFront = true;
                EZPhoto* ep = [[EZPhoto alloc] init];
                //ed.pid = ++photoCount;
                ep.asset = asset;
                ep.isLocal = true;
                ed.myPhoto = ep;
                //EZDEBUG(@"Before size");
                ep.size = [asset defaultRepresentation].dimensions;
                [albumPage addPhoto:ed];
                //[coverImage setImage:[[asset defaultRepresentation] fullScreenImage]];
            } failure:^(NSError* err){
                EZDEBUG(@"Error:%@", err);
            }];
        }
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZScreenSlide block:^(NSNumber* index){
        EZDEBUG(@"Will switch to:%i", index.intValue);
        [scrollContainer setIndex:index.intValue animated:YES slide:YES];
    }];
    
    EZDEBUG(@"main thead:%i",(int)[NSThread currentThread]);
    [[EZMessageCenter getInstance] registerEvent:EZCameraIsReady block:^(id sender){
        EZDEBUG(@"I will hide the cover view, %i",(int)[NSThread currentThread]);
        [UIView animateWithDuration:0.3 animations:^(){
            v3.view.alpha = 0;
        }];
    }];
    
    return scrollContainer;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _cameraRaised = false;
    [EZTestSuites testAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //self.window.backgroundColor = [UIColor greenColor];
    //[[EZDataUtil getInstance] loadAlbumPhoto:0 limit:100 success:^(NSArray* phs){
    //    EZDEBUG(@"returned size:%i", phs.count);
    //} failure:^(NSError* err){
    //    EZDEBUG(@"err:%@", err);
    //}];
    EZDEBUG(@"before get scrollView");
    self.window.rootViewController = [self createScrollView];
    EZDEBUG(@"After get scrollView");
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:[UIDevice currentDevice]];
    EZDEBUG(@"Register orientation change");
    [self.window makeKeyAndVisible];
    EZDEBUG(@"Visible enabled");
    return YES;
}

- (BOOL)applicationOld:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _cameraRaised = false;
    [EZTestSuites testAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    EZMainPage* mainPage = [[EZMainPage alloc] init];
    EZTiltMainView* tiltPage = [[EZTiltMainView alloc] init];
    EZViewContainer* container = [[EZViewContainer alloc] init];
    container.zoomInView = mainPage;
    container.zoomOutView = tiltPage;
    [container showView:mainPage];
    int currentPerson = [[EZDataUtil getInstance] getCurrentPersonID];
    EZDEBUG(@"Current personID:%i", currentPerson);
    EZQueryBlock qb = ^(int start, int limit, EZEventBlock success, EZEventBlock failure){
        [[EZDataUtil getInstance] loadAlbumAsDisplayPhoto:start limit:limit success:success failure:failure];
    };
    EZAlbumCollectionPage* albumPage = [EZAlbumCollectionPage createGridAlbumPage:true ownID:currentPerson queryBlock:qb];
    //albumPage.combinedPhotos = [[NSMutableArray alloc] initWithArray:[self getDummyPhotos]];
    //I would like to get the photo taking screen show off
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:[UIDevice currentDevice]];
    UINavigationController* rootNav = [[UINavigationController alloc] initWithRootViewController:albumPage];
    self.window.rootViewController = rootNav;
    EZContactsPage* contactPage = [[EZContactsPage alloc] initPage];
    contactPage.contacts = [self createPersons];
    //self.window.rootViewController = contactPage;
    
    self.window.backgroundColor = [UIColor greenColor];
    [self.window makeKeyAndVisible];
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
