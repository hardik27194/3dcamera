//
//  main.m
//  FeatherCV
//
//  Created by xietian on 13-11-21.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EZAppDelegate.h"
#import "EZUIApplication.h"
#import "EZDataUtil.h"

int main(int argc, char * argv[])
{
    @try {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, NSStringFromClass([EZUIApplication class]), NSStringFromClass([EZAppDelegate class]));
        }

    }
    @catch (NSException *exception) {
        EZDEBUG(@"Encounter exception:%@, %@", exception, [exception callStackSymbols]);
        [MobClick event:EZExceptionQuit label:exception.name];
        [[EZDataUtil getInstance]remoteDebug:[NSString stringWithFormat:@"exception:%@,%@", exception, [exception callStackSymbols]] isSync:YES];
    }
    
}
