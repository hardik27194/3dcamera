//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Glow)

@property (nonatomic, readonly) UIView* glowView;

- (void) showWhiteRadius;


- (void) hideWhiteRadius:(CGFloat)delay;

// Fade up, then down.
- (void) glowOnce;

- (void) glowOnce:(CGFloat)time;

// Useful for indicating "this object should be over there"
- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView*)view;

- (void) startGlowing;

- (void) startGlowing:(CGFloat)duration;


- (void) startGlowingWithColor:(UIColor*)color intensity:(CGFloat)intensity;

- (void) stopGlowing;

@end
