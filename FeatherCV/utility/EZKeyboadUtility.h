//
//  EZKeyboadUtility.h
//  ShowHair
//
//  Created by xietian on 13-4-5.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>


//All the key board operation will be handled in this class
//
@interface EZKeyboadUtility : NSObject

@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, assign) BOOL keyboardRaised;

- (CGRect) keyboardFrameToView:(UIView*)dest;

+ (EZKeyboadUtility*) getInstance;

@end
