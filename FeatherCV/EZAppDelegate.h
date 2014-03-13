//
//  EZAppDelegate.h
//  FeatherCV
//
//  Created by xietian on 13-11-21.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAnimationUtil.h"

@interface EZAppDelegate : UIResponder<UIApplicationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EZAnimInterface>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) BOOL cameraRaised;

//The block will get executed at the timer. 
@property (nonatomic, strong) EZEventBlock timerBlock;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
