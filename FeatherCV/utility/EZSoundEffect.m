//
//  EZSoundEffect.m
//  FeatherCV
//
//  Created by xietian on 13-12-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZSoundEffect.h"


@implementation EZSoundEffect

- (id)initWithSoundNamed:(NSString *)filename
{
    if ((self = [super init]))
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil)
        {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError){
                EZDEBUG(@"Successfully load:%@", filename);
                soundID = theSoundID;
            }else{
                EZDEBUG(@"Error loading:%@", filename);
            }
        }
    }
    return self;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)play
{
    AudioServicesPlaySystemSound(soundID);
}

@end