//
//  UIView+Shadow.h
//  Shadow Maker Example
//
//  Created by Philip Yu on 5/14/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    kBorderCeil = 1977,
    kBorderBottom,
    kBorderLeft,
    kBorderRight,
    kBorderAll
} EZBorderType;

@interface UIView (Shadow)

- (void) makeInsetShadow;
- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color;
- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;


- (UIImageView*) loadBorder:(NSString*)imageFile tag:(NSInteger)tag;
- (void) makeImageShadow;

- (void) makeImageShadow:(EZBorderType)borderType;

- (void) removeImageShadow;

- (void) removeImageBorder:(EZBorderType)borderType;

- (void) adjustImageShadowSize:(CGSize)size;

- (void) removeInsetShadow;

- (void) adjustShadowSize:(CGSize)size;

- (UIView*) getShadowView;

- (UIImage*) createBlurImage;

- (UIImageView*) createBlurImageView;

@end
