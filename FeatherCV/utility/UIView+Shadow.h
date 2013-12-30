//
//  UIView+Shadow.h
//  Shadow Maker Example
//
//  Created by Philip Yu on 5/14/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (Shadow)

- (void) makeInsetShadow;
- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color;
- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;

- (void) makeImageShadow;

- (void) removeImageShadow;

- (void) adjustImageShadowSize:(CGSize)size;

- (void) removeInsetShadow;

- (void) adjustShadowSize:(CGSize)size;

- (UIView*) getShadowView;

@end