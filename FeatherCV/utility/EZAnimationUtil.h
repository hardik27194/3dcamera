//
//  EZAnimationUtil.h
//  FeatherCV
//
//  Created by xietian on 14-2-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EZAnimInterface <NSObject>

- (BOOL) animate;

@end

@interface EZAnimationUtil : NSObject

SINGLETON_FOR_HEADER(EZAnimationUtil)


@property (nonatomic, readonly, strong) NSMutableArray* array;
@property (nonatomic, readonly, assign) CFMutableSetRef animations;
@property (nonatomic, readonly, strong) CADisplayLink *displayLink;
@property (nonatomic, readonly, assign) BOOL pauseAnimation;
- (void) addAnimation:(NSObject<EZAnimInterface> *)object;
- (void) removeAnimations:(NSObject<EZAnimInterface> *)object;

@end
