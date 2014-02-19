//
//  EZAnimationUtil.m
//  FeatherCV
//
//  Created by xietian on 14-2-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZAnimationUtil.h"


void animateAllSubscribedAppliedFunction(const void *value, void *context);


void animateAllSubscribedAppliedFunction(const void *value, void *context) {
    NSObject<EZAnimInterface>* anim = (__bridge NSObject<EZAnimInterface> *)value;
	if([anim animate]){
        [[EZAnimationUtil sharedEZAnimationUtil] removeAnimations:anim];
    };
    //[(__bridge NSObject<EZAnimInterface> *)value animate];
}


@implementation EZAnimationUtil

SINGLETON_FOR_CLASS(EZAnimationUtil)

- (id) init
{
    self = [super init];
    if(self){
        _animations = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
		[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

//This is a thread safe way of doing things?
//If it is I will be very happy
- (void) addAnimation:(NSObject<EZAnimInterface> *)object {
	CFSetAddValue(_animations, (__bridge const void*)object);
}

- (void) removeAnimations:(NSObject<EZAnimInterface> *)object {
	CFSetRemoveValue(_animations, (__bridge const void*)object);
}

- (void) handleDisplayLink:(CADisplayLink *)displayLink {
	if(!_pauseAnimation){
        CFSetApplyFunction(_animations, animateAllSubscribedAppliedFunction, NULL);
    }
}

- (void) dealloc {
	[_displayLink invalidate];
	CFRelease(_animations);
}


@end
