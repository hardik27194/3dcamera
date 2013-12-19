//
//  EZSoundEffect.h
//  FeatherCV
//
//  Created by xietian on 13-12-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

@interface EZSoundEffect : NSObject
{
    SystemSoundID soundID;
}

- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;

@end
