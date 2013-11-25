//
//  EZUIUtility.h
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EZAppConstants.h"


#define randBack(color)  [[EZUIUtility sharedEZUIUtility] getBackgroundColor:color]
//Put UI related functionality here
@interface EZUIUtility : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL cameraRaised;

@property (nonatomic, strong) EZEventBlock completed;

@property (nonatomic, strong) NSArray* colors;

//This method will get called by the EZClickView.
//If pass nil mean pick color randomly.
- (UIColor*) getBackgroundColor:(UIColor*)color;

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController*)controller completed:(EZEventBlock)block;

- (UIImagePickerController*) getCamera:(BOOL)isAlbum completed:(EZEventBlock)block;


//+ (EZUIUtility*) getInstance;
SINGLETON_FOR_HEADER(EZUIUtility);

@end
